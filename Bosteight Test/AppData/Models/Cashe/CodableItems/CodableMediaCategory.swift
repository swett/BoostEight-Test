//
//  CodableMediaCategory.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 10.03.2026.
//

import Foundation
struct CodableMediaCategory: Codable {
    let assetIDs: [String]
    let assetSizes: [String: Int64]
}

