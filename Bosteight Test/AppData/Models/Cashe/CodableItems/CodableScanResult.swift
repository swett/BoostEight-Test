//
//  CodableScanResult.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 10.03.2026.
//

import Foundation
import Photos
struct CodableScanResult: Codable {
    let totalCount: Int
    let totalSize: Int64
    let videoCompressor: CodableVideoCompressorResult
    let media: CodableMediaResult
}


extension CodableScanResult {

    init(from result: ScanResult) {
        totalCount = result.totalCount
        totalSize = result.totalSize
        videoCompressor = CodableVideoCompressorResult(from: result.videoCompressor)
        media = CodableMediaResult(from: result.media)
    }

    func toScanResult(existingIDs: Set<String>) -> ScanResult {
        let vc = videoCompressor.toResult(existingIDs: existingIDs)
        let m  = media.toResult(existingIDs: existingIDs)

        return ScanResult(
            totalCount: m.screenshots.count + m.livePhotos.count
                + m.screenRecordings.count + m.duplicatePhotos.count
                + m.similarPhotos.count + m.similarVideos.count,
            totalSize: m.screenshots.totalSize + m.livePhotos.totalSize
                + m.screenRecordings.totalSize + m.duplicatePhotos.totalSize
                + m.similarPhotos.totalSize + m.similarVideos.totalSize,
            videoCompressor: vc,
            media: m
        )
    }
}

extension CodableVideoCompressorResult {

    init(from result: VideoCompressorResult) {
        count = result.count
        totalSize = result.totalSize
        assetIDs = result.assets.map(\.localIdentifier)
        assetSizes = result.assetSizes
    }

    func toResult(existingIDs: Set<String>) -> VideoCompressorResult {
        let filtered = assetIDs.filter { existingIDs.contains($0) }
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: filtered, options: nil)

        var assets: [PHAsset] = []
        fetchResult.enumerateObjects { a, _, _ in assets.append(a) }

        var sizes: [String: Int64] = [:]
        var total: Int64 = 0
        for asset in assets {
            if let s = assetSizes[asset.localIdentifier] {
                sizes[asset.localIdentifier] = s
                total += s
            }
        }

        return VideoCompressorResult(
            count: assets.count,
            totalSize: total,
            assets: assets,
            assetSizes: sizes
        )
    }
}

extension CodableMediaResult {

    init(from result: MediaResult) {
        screenshots     = CodableMediaCategory(from: result.screenshots)
        livePhotos      = CodableMediaCategory(from: result.livePhotos)
        screenRecordings = CodableMediaCategory(from: result.screenRecordings)
        duplicatePhotos = CodableGroupedCategory(from: result.duplicatePhotos)
        similarPhotos   = CodableGroupedCategory(from: result.similarPhotos)
        similarVideos   = CodableGroupedCategory(from: result.similarVideos)
    }

    func toResult(existingIDs: Set<String>) -> MediaResult {
        MediaResult(
            screenshots:      screenshots.toCategory(existingIDs: existingIDs),
            livePhotos:       livePhotos.toCategory(existingIDs: existingIDs),
            screenRecordings: screenRecordings.toCategory(existingIDs: existingIDs),
            duplicatePhotos:  duplicatePhotos.toCategory(existingIDs: existingIDs),
            similarPhotos:    similarPhotos.toCategory(existingIDs: existingIDs),
            similarVideos:    similarVideos.toCategory(existingIDs: existingIDs)
        )
    }
}

