//
//  CodableGroupedCategory.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 10.03.2026.
//

import Foundation
import Photos
struct CodableGroupedCategory: Codable {
    let groups: [[String]]   // groups of asset IDs
    let assetSizes: [String: Int64]
}


extension CodableGroupedCategory {

    init(from category: MediaCategory) {
        groups     = (category.groupedAssets ?? []).map { $0.map(\.localIdentifier) }
        assetSizes = category.assetSizes
    }

    func toCategory(existingIDs: Set<String>) -> MediaCategory {
        // Filter each group, remove groups with < 2 remaining assets
        let filteredGroups = groups
            .map { $0.filter { existingIDs.contains($0) } }
            .filter { $0.count > 1 }

        guard !filteredGroups.isEmpty else {
            return MediaCategory(count: 0, totalSize: 0, allAssets: [], groupedAssets: [], assetSizes: [:])
        }

        let allIDs = filteredGroups.flatMap { $0 }
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: allIDs, options: nil)

        var assetMap: [String: PHAsset] = [:]
        fetchResult.enumerateObjects { a, _, _ in assetMap[a.localIdentifier] = a }

        let resolvedGroups: [[PHAsset]] = filteredGroups.compactMap { ids in
            let assets = ids.compactMap { assetMap[$0] }
            return assets.count > 1 ? assets : nil
        }

        let flat = resolvedGroups.flatMap { $0 }
        var sizes: [String: Int64] = [:]
        var total: Int64 = 0
        for asset in flat {
            if let s = assetSizes[asset.localIdentifier] {
                sizes[asset.localIdentifier] = s
                total += s
            }
        }

        return MediaCategory(
            count: flat.count,
            totalSize: total,
            allAssets: flat,
            groupedAssets: resolvedGroups,
            assetSizes: sizes
        )
    }
}
