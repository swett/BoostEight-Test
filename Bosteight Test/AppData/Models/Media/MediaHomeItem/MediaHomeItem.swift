//
//  MediaHomeItem.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 03.03.2026.
//

import Foundation
struct MediaHomeItem: Identifiable, Hashable {
    let id: MediaSubcategory
    let title: String
    let count: Int
    let totalSize: Int64
    let previewAssetIDs: [String]
}
