//
//  ScanResults.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import Foundation

struct ScanResult {
    let totalCount: Int
    let totalSize: Int64
    let videoCompressor: VideoCompressorResult
    let media: MediaResult
}


extension ScanResult {
    static var empty: ScanResult {
        ScanResult(
            totalCount: 0,
            totalSize: 0,
            videoCompressor: VideoCompressorResult(
                count: 0,
                totalSize: 0,
                assets: [],
                assetSizes: [:]
            ),
            media: MediaResult(
                screenshots:      .empty,
                livePhotos:       .empty,
                screenRecordings: .empty,
                duplicatePhotos:  .empty,
                similarPhotos:    .empty,
                similarVideos:    .empty
            )
        )
    }
}
