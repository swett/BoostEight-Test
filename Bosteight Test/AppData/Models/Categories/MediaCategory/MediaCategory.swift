//
//  MediaCategory.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import Foundation
import Photos

struct MediaCategory {
    let count: Int
    let totalSize: Int64

    let allAssets: [PHAsset]
    let groupedAssets: [[PHAsset]]?
    let assetSizes: [String: Int64] 
}


extension MediaCategory {
    static var empty: MediaCategory {
        MediaCategory(
            count: 0,
            totalSize: 0,
            allAssets: [],
            groupedAssets: nil,
            assetSizes: [:]
        )
    }
}
