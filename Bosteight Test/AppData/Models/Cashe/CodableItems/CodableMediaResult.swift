//
//  CodableMediaResult.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 10.03.2026.
//

import Foundation
import Photos
struct CodableMediaResult: Codable {
    let screenshots: CodableMediaCategory
    let livePhotos: CodableMediaCategory
    let screenRecordings: CodableMediaCategory
    let duplicatePhotos: CodableGroupedCategory
    let similarPhotos: CodableGroupedCategory
    let similarVideos: CodableGroupedCategory
}


extension CodableMediaCategory {

    init(from category: MediaCategory) {
        assetIDs   = category.allAssets.map(\.localIdentifier)
        assetSizes = category.assetSizes
    }

    func toCategory(existingIDs: Set<String>) -> MediaCategory {
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

        return MediaCategory(
            count: assets.count,
            totalSize: total,
            allAssets: assets,
            groupedAssets: nil,
            assetSizes: sizes
        )
    }
}

