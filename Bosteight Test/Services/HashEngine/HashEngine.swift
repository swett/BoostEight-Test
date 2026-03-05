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
    
    struct CombinedHash {
        let aHash: UInt64
        let featurePrint: VNFeaturePrintObservation?
    }
    
    // MARK: - Public API
    
    func makeHash(for asset: PHAsset) async -> CombinedHash? {

        let id = asset.localIdentifier

        // 1. проверяем cache
        if let cached = await HashCache.shared.hash(for: id) {
            return CombinedHash(aHash: cached, featurePrint: nil)
        }

        // 2. загружаем изображение
        guard let image = await requestImage(for: asset) else { return nil }

        // 3. считаем hash
        let aHash = makeAverageHash(from: image)

        // 4. сохраняем в cache
        await HashCache.shared.save(hash: aHash, for: id)

        // 5. feature print (для similar)
        let feature = makeFeaturePrint(from: image)

        return CombinedHash(
            aHash: aHash,
            featurePrint: feature
        )
    }
    
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

private extension HashEngine {
    
    func requestImage(for asset: PHAsset) async -> CGImage? {
        
        await withCheckedContinuation { continuation in
            
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .fastFormat
            options.resizeMode = .fast
            
            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 224, height: 224),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                
                continuation.resume(returning: image?.cgImage)
            }
        }
    }
    
    func makeAverageHash(from cgImage: CGImage) -> UInt64 {
        
        let width = 8
        let height = 8
        
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return 0 }
        
        let pixels = data.bindMemory(to: UInt8.self, capacity: width * height)
        
        var total = 0
        for i in 0..<width*height {
            total += Int(pixels[i])
        }
        
        let avg = total / (width * height)
        
        var hash: UInt64 = 0
        for i in 0..<width*height {
            if pixels[i] > avg {
                hash |= 1 << i
            }
        }
        
        return hash
    }
    
    func makeFeaturePrint(from cgImage: CGImage) -> VNFeaturePrintObservation? {
        
        let request = VNGenerateImageFeaturePrintRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        try? handler.perform([request])
        
        return request.results?.first as? VNFeaturePrintObservation
    }
    

}
