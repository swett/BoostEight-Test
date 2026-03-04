//
//  MockScanStore.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation
import Photos

final class MockScanStore: ScanStoreProtocol {

    @Published var scanResult: ScanResult

    init() {
        self.scanResult = MockDataFactory.makeScanResult()
    }

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

    func deleteAssets(ids: [String]) async throws {}
    func refreshAfterDeletion(ids: [String]) {}
}
