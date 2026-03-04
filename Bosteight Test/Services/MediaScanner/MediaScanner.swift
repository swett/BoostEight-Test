//
//  MediaScanner.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import Foundation
import Photos
import UIKit
import AVFoundation

actor MediaScanner {
    
    private let imageManager = PHCachingImageManager()
    private let hashEngine = HashEngine()
    private var isCancelled = false
    
    func cancel() {
        isCancelled = true
    }
    
    // Главная точка входа
    func scan() -> AsyncStream<(ScanProgress, ScanResult?)> {
        AsyncStream { continuation in
            
            Task {
                var globalSizeMap: [String: Int64] = [:]
                isCancelled = false
                
                let assets = fetchAllAssets()
                
                var totalCount = 0
                var totalSize: Int64 = 0
                var videoSize: Int64 = 0
                
                var videos: [PHAsset] = []
                var photos: [PHAsset] = []
                var screenshots: [PHAsset] = []
                var livePhotos: [PHAsset] = []
                var screenRecordings: [PHAsset] = []
                
                // ==========================
                // PHASE 1 — METADATA
                // ==========================
                
                let totalAssets = assets.count
                var processed = 0
                
                for asset in assets {
                    
                    if isCancelled { break }
                    
                    totalCount += 1
                    
                    let size = fastAssetSize(asset)
                    globalSizeMap[asset.localIdentifier] = size
                    totalSize += size
                    
                    switch asset.mediaType {
                    case .video:
                        videos.append(asset)
                        videoSize += size
                        
                        if isScreenRecording(asset) {
                            screenRecordings.append(asset)
                        }
                        
                    case .image:
                        photos.append(asset)
                        
                        if asset.mediaSubtypes.contains(.photoScreenshot) {
                            screenshots.append(asset)
                        }
                        
                        if asset.mediaSubtypes.contains(.photoLive) {
                            livePhotos.append(asset)
                        }
                        
                    default: break
                    }
                    
                    processed += 1
                    
                    let progress = Double(processed) / Double(totalAssets)
                    
                    continuation.yield((
                        ScanProgress(phase: .metadata, progress: progress),
                        nil
                    ))
                }
                
                if isCancelled {
                    continuation.finish()
                    return
                }
                
                // ==========================
                // PHASE 2 — DUPLICATES
                // ==========================
                
                let duplicateGroups = await detectDuplicatePhotos(
                    from: photos,
                    continuation: continuation
                )
                
                if isCancelled {
                    continuation.finish()
                    return
                }
                
                // ==========================
                // PHASE 3 — SIMILAR
                // ==========================
                
                let similarGroups = await detectSimilarPhotos(
                    from: photos,
                    continuation: continuation
                )
                
                let similarVideoGroups = detectSimilarVideos(from: videos)
                
                // ==========================
                // FINISH
                // ==========================
                
                let result = buildResult(
                    totalCount: totalCount,
                    totalSize: totalSize,
                    videoSize: videoSize,
                    videos: videos,
                    screenshots: screenshots,
                    livePhotos: livePhotos,
                    screenRecordings: screenRecordings,
                    duplicateGroups: duplicateGroups,
                    similarGroups: similarGroups,
                    similarVideoGroups: similarVideoGroups,
                    sizeMap: globalSizeMap        // ← добавляем
                )
                
                continuation.yield((
                    ScanProgress(phase: .finished, progress: 1),
                    result
                ))
                
                continuation.finish()
            }
        }
    }
}


private extension MediaScanner {
    
    func fetchAllAssets() -> [PHAsset] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let result = PHAsset.fetchAssets(with: options)
        
        var assets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        return assets
    }
}


private extension MediaScanner {
    
    func assetSize(_ asset: PHAsset) async -> Int64 {
        await withCheckedContinuation { continuation in
            
            let resources = PHAssetResource.assetResources(for: asset)
            
            guard let resource = resources.first else {
                continuation.resume(returning: 0)
                return
            }
            
            var size: Int64 = 0
            
            let options = PHAssetResourceRequestOptions()
            options.isNetworkAccessAllowed = true
            
            PHAssetResourceManager.default().requestData(
                for: resource,
                options: options,
                dataReceivedHandler: { data in
                    size += Int64(data.count)
                },
                completionHandler: { _ in
                    continuation.resume(returning: size)
                }
            )
        }
    }
    
    func fastAssetSize(_ asset: PHAsset) -> Int64 {
        let resources = PHAssetResource.assetResources(for: asset)
        guard let resource = resources.first else { return 0 }
        return resource.value(forKey: "fileSize") as? Int64 ?? 0
    }
}

private extension MediaScanner {
    
    func detectDuplicatePhotos(
        from photos: [PHAsset],
        continuation: AsyncStream<(ScanProgress, ScanResult?)>.Continuation
    ) async -> [[PHAsset]] {
        
        var hashMap: [UInt64: [PHAsset]] = [:]
        
        let chunks = photos.chunked(into: 40)
        let total = chunks.count
        
        for (index, chunk) in chunks.enumerated() {
            
            if isCancelled { break }
            
            await withTaskGroup(of: (UInt64, PHAsset)?.self) { group in
                
                for asset in chunk {
                    group.addTask {
                        if let combined = await self.hashEngine.makeHash(for: asset) {
                            return (combined.aHash, asset)
                        }
                        return nil
                    }
                }
                
                for await result in group {
                    if let (hash, asset) = result {
                        hashMap[hash, default: []].append(asset)
                    }
                }
            }
            
            let progress = Double(index + 1) / Double(total)
            
            continuation.yield((
                ScanProgress(phase: .duplicates, progress: progress),
                nil
            ))
        }
        
        return hashMap.values.filter { $0.count > 1 }
    }
}


private extension MediaScanner {
    
    func detectSimilarPhotos(
        from photos: [PHAsset],
        continuation: AsyncStream<(ScanProgress, ScanResult?)>.Continuation
    ) async -> [[PHAsset]] {
        
        var hashes: [(PHAsset, HashEngine.CombinedHash)] = []
        
        for asset in photos {
            if let hash = await hashEngine.makeHash(for: asset) {
                hashes.append((asset, hash))
            }
        }
        
        var groups: [[PHAsset]] = []
        var visited = Set<String>()
        
        let total = hashes.count
        
        for (index, (asset, hash)) in hashes.enumerated() {
            
            if visited.contains(asset.localIdentifier) { continue }
            
            var group = [asset]
            
            for (otherAsset, otherHash) in hashes {
                
                if asset.localIdentifier == otherAsset.localIdentifier { continue }
                
                let hamming = await hashEngine.hammingDistance(hash.aHash, otherHash.aHash)
                
                if hamming < 6 {
                    group.append(otherAsset)
                    visited.insert(otherAsset.localIdentifier)
                    continue
                }
                
                if let f1 = hash.featurePrint,
                   let f2 = otherHash.featurePrint,
                   let distance = await hashEngine.featureDistance(f1, f2),
                   distance < 0.1 {
                    
                    group.append(otherAsset)
                    visited.insert(otherAsset.localIdentifier)
                }
            }
            
            if group.count > 1 {
                groups.append(group)
            }
            
            let progress = Double(index + 1) / Double(total)
            
            continuation.yield((
                ScanProgress(phase: .similar, progress: progress),
                nil
            ))
        }
        
        return groups
    }
}

private extension MediaScanner {
    
    func isScreenRecording(_ asset: PHAsset) -> Bool {
        guard asset.mediaType == .video else { return false }
        
        let resources = PHAssetResource.assetResources(for: asset)
        
        guard let filename = resources.first?.originalFilename else {
            return false
        }
        
        return filename.contains("ScreenRecording")
    }
}


private extension MediaScanner {
    
    func computeHash(for asset: PHAsset) async -> UInt64? {
        
        await withCheckedContinuation { continuation in
            
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.resizeMode = .fast
            options.deliveryMode = .fastFormat
            
            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 64, height: 64),
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                
                guard let image = image,
                      let cgImage = image.cgImage else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let hash = self.averageHash(from: cgImage)
                continuation.resume(returning: hash)
            }
        }
    }
}

private extension MediaScanner {
    
    func averageHash(from cgImage: CGImage) -> UInt64 {
        
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
        
        var total: Int = 0
        for i in 0..<width * height {
            total += Int(pixels[i])
        }
        
        let avg = total / (width * height)
        
        var hash: UInt64 = 0
        
        for i in 0..<width * height {
            if pixels[i] > avg {
                hash |= 1 << i
            }
        }
        
        return hash
    }
    
    func hammingDistance(_ a: UInt64, _ b: UInt64) -> Int {
        (a ^ b).nonzeroBitCount
    }
}


private extension MediaScanner {
    
    func detectSimilarVideos(from videos: [PHAsset]) -> [[PHAsset]] {
        
        var groups: [[PHAsset]] = []
        var visited = Set<String>()
        
        for video in videos {
            
            if visited.contains(video.localIdentifier) { continue }
            
            var group = [video]
            
            for other in videos {
                if video.localIdentifier == other.localIdentifier { continue }
                
                if abs(video.duration - other.duration) < 1 {
                    group.append(other)
                    visited.insert(other.localIdentifier)
                }
            }
            
            if group.count > 1 {
                groups.append(group)
            }
        }
        
        return groups
    }
}


private extension MediaScanner {
    
    func buildResult(
        totalCount: Int,
        totalSize: Int64,
        videoSize: Int64,
        videos: [PHAsset],
        screenshots: [PHAsset],
        livePhotos: [PHAsset],
        screenRecordings: [PHAsset],
        duplicateGroups: [[PHAsset]],
        similarGroups: [[PHAsset]],
        similarVideoGroups: [[PHAsset]],
        sizeMap: [String: Int64]
    ) -> ScanResult {

        ScanResult(
            totalCount: totalCount,
            totalSize: totalSize,
            videoCompressor: VideoCompressorResult(
                count: videos.count,
                totalSize: videoSize,
                previewAsset: videos.first
            ),
            media: MediaResult(
                screenshots: buildCategory(from: screenshots, sizeMap: sizeMap),
                livePhotos: buildCategory(from: livePhotos, sizeMap: sizeMap),
                screenRecordings: buildCategory(from: screenRecordings, sizeMap: sizeMap),
                duplicatePhotos: buildGroupedCategory(duplicateGroups, sizeMap: sizeMap),
                similarPhotos: buildGroupedCategory(similarGroups, sizeMap: sizeMap),
                similarVideos: buildGroupedCategory(similarVideoGroups, sizeMap: sizeMap)
            )
        )
    }
    
    func buildCategory(
        from assets: [PHAsset],
        sizeMap: [String: Int64]
    ) -> MediaCategory {

        var filteredSizeMap: [String: Int64] = [:]
        var totalSize: Int64 = 0

        for asset in assets {
            if let size = sizeMap[asset.localIdentifier] {
                filteredSizeMap[asset.localIdentifier] = size
                totalSize += size
            }
        }

        return MediaCategory(
            count: assets.count,
            totalSize: totalSize,
            allAssets: assets,
            groupedAssets: nil,
            assetSizes: filteredSizeMap
        )
    }
    
    func buildGroupedCategory(
        _ groups: [[PHAsset]],
        sizeMap: [String: Int64]
    ) -> MediaCategory {

        let flat = groups.flatMap { $0 }

        var filteredSizeMap: [String: Int64] = [:]
        var totalSize: Int64 = 0

        for asset in flat {
            if let size = sizeMap[asset.localIdentifier] {
                filteredSizeMap[asset.localIdentifier] = size
                totalSize += size
            }
        }

        return MediaCategory(
            count: flat.count,
            totalSize: totalSize,
            allAssets: flat,
            groupedAssets: groups,
            assetSizes: filteredSizeMap
        )
    }
}
