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
    
    // MARK: - PUBLIC
    
    func scan() async -> ScanResult {
        
        let assets = fetchAllAssets()
        
        var totalCount = 0
        var totalSize: Int64 = 0
        var videoSize: Int64 = 0
        var videos: [PHAsset] = []
        var photos: [PHAsset] = []
        
        var screenshots: [PHAsset] = []
        var livePhotos: [PHAsset] = []
        var screenRecordings: [PHAsset] = []
        
        // 1️⃣ Быстрая первичная категоризация
        for asset in assets {
            totalCount += 1
            
            let size = fastAssetSize(asset)
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
                
            default:
                break
            }
        }
        
        // 2️⃣ Дубликаты и похожие фото
        let duplicateGroups = await detectDuplicatePhotos(from: photos)
        let similarGroups = await detectSimilarPhotos(from: photos)
        
        // 3️⃣ Похожие видео
        let similarVideoGroups = detectSimilarVideos(from: videos)
        
        // 4️⃣ Сбор результата
        return buildResult(
            totalCount: totalCount,
            totalSize: totalSize,
            videoSize: videoSize,
            videos: videos,
            screenshots: screenshots,
            livePhotos: livePhotos,
            screenRecordings: screenRecordings,
            duplicateGroups: duplicateGroups,
            similarGroups: similarGroups,
            similarVideoGroups: similarVideoGroups
        )
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
    
    private func fastAssetSize(_ asset: PHAsset) -> Int64 {
        
        let resources = PHAssetResource.assetResources(for: asset)
        
        guard let resource = resources.first else {
            return 0
        }
        
        if let fileSize = resource.value(forKey: "fileSize") as? Int64 {
            return fileSize
        }
        
        return 0
    }
}

private extension MediaScanner {
    
    func detectDuplicatePhotos(from photos: [PHAsset]) async -> [[PHAsset]] {
        
        var hashMap: [UInt64: [PHAsset]] = [:]
        
        let chunks = photos.chunked(into: 40)
        
        for chunk in chunks {
            
            await withTaskGroup(of: (UInt64, PHAsset)?.self) { group in
                
                for asset in chunk {
                    group.addTask {
                        if let hash = await self.computeHash(for: asset) {
                            return (hash, asset)
                        }
                        return nil
                    }
                }
                
                for await result in group {
                    guard let (hash, asset) = result else { continue }
                    hashMap[hash, default: []].append(asset)
                }
            }
        }
        
        return hashMap.values.filter { $0.count > 1 }
    }
}


private extension MediaScanner {
    
    func detectSimilarPhotos(from photos: [PHAsset]) async -> [[PHAsset]] {
        
        var hashes: [(PHAsset, UInt64)] = []
        
        for asset in photos {
            if let hash = await computeHash(for: asset) {
                hashes.append((asset, hash))
            }
        }
        
        var groups: [[PHAsset]] = []
        var visited = Set<String>()
        
        for (asset, hash) in hashes {
            
            if visited.contains(asset.localIdentifier) { continue }
            
            var group = [asset]
            
            for (otherAsset, otherHash) in hashes {
                if asset.localIdentifier == otherAsset.localIdentifier { continue }
                
                if hammingDistance(hash, otherHash) < 5 {
                    group.append(otherAsset)
                    visited.insert(otherAsset.localIdentifier)
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
        similarVideoGroups: [[PHAsset]]
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
                screenshots: buildCategory(from: screenshots),
                livePhotos: buildCategory(from: livePhotos),
                screenRecordings: buildCategory(from: screenRecordings),
                duplicatePhotos: buildGroupedCategory(duplicateGroups),
                similarPhotos: buildGroupedCategory(similarGroups),
                similarVideos: buildGroupedCategory(similarVideoGroups)
            )
        )
    }
    
    func buildCategory(from assets: [PHAsset]) -> MediaCategory {
        MediaCategory(
            count: assets.count,
            totalSize: 0,
            previewAssets: Array(assets.prefix(2))
        )
    }
    
    func buildGroupedCategory(_ groups: [[PHAsset]]) -> MediaCategory {
        let flat = groups.flatMap { $0 }
        return MediaCategory(
            count: flat.count,
            totalSize: 0,
            previewAssets: Array(flat.prefix(2))
        )
    }
}
