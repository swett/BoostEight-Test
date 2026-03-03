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
    let previewAssets: [PHAsset]   // максимум 2
}
