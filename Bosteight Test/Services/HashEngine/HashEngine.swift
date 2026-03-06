//
//  HashEngine.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//


import Photos
import UIKit
import Vision

actor HashEngine {

    private let imageManager = PHCachingImageManager()
    // In-memory cache for featurePrints (evicted on memory pressure)
    private let featureCache = NSCache<NSString, VNFeaturePrintObservation>()

    struct CombinedHash {
        let aHash: UInt64
        let featurePrint: VNFeaturePrintObservation?
    }

    func makeHash(for asset: PHAsset) async -> CombinedHash? {
        let id = asset.localIdentifier

        // aHash: use tiny 16x16 image — plenty for an 8x8 hash
        let aHash: UInt64
        if let cached = await HashCache.shared.hash(for: id) {
            aHash = cached
        } else {
            // ← Request only 16×16 instead of 224×224
            guard let small = await requestImage(for: asset, size: CGSize(width: 16, height: 16))
            else { return nil }
            aHash = makeAverageHash(from: small)
            await HashCache.shared.save(hash: aHash, for: id)
        }

        // featurePrint: only load 224×224 when needed, reuse NSCache
        let feature: VNFeaturePrintObservation?
        if let cached = featureCache.object(forKey: id as NSString) {
            feature = cached
        } else {
            // Lazy: return nil here, caller requests it on demand via makeFeaturePrint(for:)
            feature = nil
        }

        return CombinedHash(aHash: aHash, featurePrint: feature)
    }

    /// Call this only when featurePrint comparison is actually needed
    func makeFeaturePrint(for asset: PHAsset) async -> VNFeaturePrintObservation? {
        let id = asset.localIdentifier
        if let cached = featureCache.object(forKey: id as NSString) {
            return cached
        }
        guard let image = await requestImage(for: asset, size: CGSize(width: 224, height: 224)),
              let fp = makeFeaturePrint(from: image)
        else { return nil }
        featureCache.setObject(fp, forKey: id as NSString)
        return fp
    }

    // Sync — no await needed
    func hammingDistance(_ a: UInt64, _ b: UInt64) -> Int {
        (a ^ b).nonzeroBitCount
    }

    func featureDistance(
        _ a: VNFeaturePrintObservation,
        _ b: VNFeaturePrintObservation
    ) -> Float? {
        var distance: Float = 0
        try? a.computeDistance(&distance, to: b)
        return distance
    }
}
 extension HashEngine {

    func requestImage(for asset: PHAsset, size: CGSize) async -> CGImage? {
        await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .fastFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = false // avoid stalling on iCloud assets

            imageManager.requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                // Degraded = thumbnail not ready yet, skip it
                let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                if isDegraded { return }
                continuation.resume(returning: image?.cgImage)
            }
        }
    }

    func makeAverageHash(from cgImage: CGImage) -> UInt64 {
        let size = 8
        guard let ctx = CGContext(
            data: nil, width: size, height: size,
            bitsPerComponent: 8, bytesPerRow: size,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return 0 }

        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size, height: size))
        guard let data = ctx.data else { return 0 }

        let pixels = data.bindMemory(to: UInt8.self, capacity: size * size)
        var total = 0
        for i in 0..<size * size { total += Int(pixels[i]) }
        let avg = UInt8(total / (size * size))

        var hash: UInt64 = 0
        for i in 0..<size * size where pixels[i] > avg {
            hash |= 1 << i
        }
        return hash
    }

    func makeFeaturePrint(from cgImage: CGImage) -> VNFeaturePrintObservation? {
        let request = VNGenerateImageFeaturePrintRequest()
        try? VNImageRequestHandler(cgImage: cgImage).perform([request])
        return request.results?.first as? VNFeaturePrintObservation
    }
}
