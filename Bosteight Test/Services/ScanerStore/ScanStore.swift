//
//  ScanStore.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation
import Photos
import SwiftUI

@MainActor
final class ScanStore: ScanStoreProtocol {
    
    @Published private(set) var scanResult: ScanResult
    
    init(scanResult: ScanResult) {
        self.scanResult = scanResult
    }
    
    func assetSize(_ asset: PHAsset) -> Int64 {
        
        let resources = PHAssetResource.assetResources(for: asset)
        
        guard let resource = resources.first,
              let size = resource.value(forKey: "fileSize") as? Int64
        else { return 0 }
        
        return size
    }
    
    private func totalCount(for media: MediaResult) -> Int {
        
        return media.screenshots.count
        + media.livePhotos.count
        + media.screenRecordings.count
        + media.duplicatePhotos.count
        + media.similarPhotos.count
        + media.similarVideos.count
    }
    private func totalSize(for media: MediaResult) -> Int64 {
        
        return media.screenshots.totalSize
        + media.livePhotos.totalSize
        + media.screenRecordings.totalSize
        + media.duplicatePhotos.totalSize
        + media.similarPhotos.totalSize
        + media.similarVideos.totalSize
    }
    
    func fastAssetSize(_ asset: PHAsset) -> Int64 {
        let resources = PHAssetResource.assetResources(for: asset)
        guard let resource = resources.first else { return 0 }
        return resource.value(forKey: "fileSize") as? Int64 ?? 0
    }
}


extension ScanStore {
    
    func category(for subcategory: MediaSubcategory) -> MediaCategory {
        switch subcategory {
        case .screenshots: return scanResult.media.screenshots
        case .livePhotos: return scanResult.media.livePhotos
        case .screenRecordings: return scanResult.media.screenRecordings
        case .duplicatePhotos: return scanResult.media.duplicatePhotos
        case .similarPhotos: return scanResult.media.similarPhotos
        case .similarVideos: return scanResult.media.similarVideos
        }
    }
    
    func groupedAssets(for subcategory: MediaSubcategory) -> [[PHAsset]] {
        category(for: subcategory).groupedAssets ?? []
    }
}

extension ScanStore {
    func deleteAssets(ids: [String]) async throws {
        
        let fetchResult = PHAsset.fetchAssets(
            withLocalIdentifiers: ids,
            options: nil
        )
        
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(fetchResult)
        }
        
        refreshAfterDeletion(ids: ids)
    }
    
    func refreshAfterDeletion(ids: [String]) {

        func filter(_ category: MediaCategory) -> MediaCategory {

            let filteredAll = category.allAssets.filter {
                !ids.contains($0.localIdentifier)
            }

            let filteredGroups = category.groupedAssets?
                .map { group in
                    group.filter { !ids.contains($0.localIdentifier) }
                }
                .filter { !$0.isEmpty }

            // используем старую sizeMap
            var newSizeMap: [String: Int64] = [:]
            var newTotalSize: Int64 = 0

            for asset in filteredAll {
                if let size = category.assetSizes[asset.localIdentifier] {
                    newSizeMap[asset.localIdentifier] = size
                    newTotalSize += size
                }
            }

            return MediaCategory(
                count: filteredAll.count,
                totalSize: newTotalSize,
                allAssets: filteredAll,
                groupedAssets: filteredGroups,
                assetSizes: newSizeMap
            )
        }

        let old = scanResult.media

        let newMedia = MediaResult(
            screenshots: filter(old.screenshots),
            livePhotos: filter(old.livePhotos),
            screenRecordings: filter(old.screenRecordings),
            duplicatePhotos: filter(old.duplicatePhotos),
            similarPhotos: filter(old.similarPhotos),
            similarVideos: filter(old.similarVideos)
        )

        scanResult = ScanResult(
            totalCount:
                newMedia.screenshots.count
                + newMedia.livePhotos.count
                + newMedia.screenRecordings.count
                + newMedia.duplicatePhotos.count
                + newMedia.similarPhotos.count
                + newMedia.similarVideos.count,

            totalSize:
                newMedia.screenshots.totalSize
                + newMedia.livePhotos.totalSize
                + newMedia.screenRecordings.totalSize
                + newMedia.duplicatePhotos.totalSize
                + newMedia.similarPhotos.totalSize
                + newMedia.similarVideos.totalSize,

            videoCompressor: scanResult.videoCompressor,
            media: newMedia
        )
    }
}

extension ScanStore {
    /// Called by MainViewModel after a scan completes.
    /// Replaces the entire result — all downstream views update automatically.
    func apply(_ result: ScanResult) {
        scanResult = result
    }
}
