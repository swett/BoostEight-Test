//
//  VideoCompressorResult.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import Foundation
import Photos

struct VideoCompressorResult {

    let count: Int
    let totalSize: Int64

    let assets: [PHAsset]
    let assetSizes: [String: Int64]

    var previewAsset: PHAsset? {
        assets.first
    }
}
