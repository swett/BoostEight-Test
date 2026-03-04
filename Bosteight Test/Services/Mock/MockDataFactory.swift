//
//  MockDataFactory.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation
import Photos

enum MockDataFactory {

    static func makeScanResult() -> ScanResult {

        let fakeAssets: [PHAsset] = []

        let groupedCategory = MediaCategory(
            count: 6,
            totalSize: 120_000_000,
            allAssets: fakeAssets,
            groupedAssets: [
                fakeAssets,
                fakeAssets
            ],
            assetSizes: [:]
        )

        let gridCategory = MediaCategory(
            count: 12,
            totalSize: 300_000_000,
            allAssets: fakeAssets,
            groupedAssets: nil,
            assetSizes: [:]
        )

        return ScanResult(
            totalCount: 18,
            totalSize: 420_000_000,
            videoCompressor: VideoCompressorResult(
                count: 0,
                totalSize: 0,
                previewAsset: nil
            ),
            media: MediaResult(
                screenshots: gridCategory,
                livePhotos: gridCategory,
                screenRecordings: gridCategory,
                duplicatePhotos: groupedCategory,
                similarPhotos: groupedCategory,
                similarVideos: groupedCategory
            )
        )
    }
}
