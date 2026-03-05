//
//  MockDataFactory.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation
import Photos

enum MockDataFactory {
    // Fake asset IDs to simulate PHAsset.localIdentifier
    static let fakeVideoIDs: [String] = [
        "MOCK-VIDEO-001", "MOCK-VIDEO-002", "MOCK-VIDEO-003",
        "MOCK-VIDEO-004", "MOCK-VIDEO-005", "MOCK-VIDEO-006"
    ]
    
    static func makeVideoCompressorResult() -> VideoCompressorResult {
        // PHAsset can't be directly instantiated, so we use
        // a PHAsset fetch from the real library in production.
        // For UI preview, we pass empty assets but populate assetSizes
        // so sizeText(for:) renders correctly when assets ARE present.
        let fakeSizes: [String: Int64] = [
            "MOCK-VIDEO-001": 85_000_000,   // ~85 MB
            "MOCK-VIDEO-002": 210_000_000,  // ~210 MB
            "MOCK-VIDEO-003": 45_500_000,   // ~45.5 MB
            "MOCK-VIDEO-004": 512_000_000,  // ~512 MB
            "MOCK-VIDEO-005": 128_000_000,  // ~128 MB
            "MOCK-VIDEO-006": 1_073_741_824 // ~1 GB
        ]
        
        return VideoCompressorResult(
            count: fakeVideoIDs.count,
            totalSize: fakeSizes.values.reduce(0, +),
            assets: [],          // PHAsset can't be mocked; stays empty in preview
            assetSizes: fakeSizes
        )
    }
    
    static func makeScanResult() -> ScanResult {
        let fakeAssets: [PHAsset] = []
        
        let groupedCategory = MediaCategory(
            count: 6,
            totalSize: 120_000_000,
            allAssets: fakeAssets,
            groupedAssets: [fakeAssets, fakeAssets],
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
            videoCompressor: makeVideoCompressorResult(), // ← updated
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
