//
//  CodableVideoCompressorResult.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 10.03.2026.
//

import Foundation

struct CodableVideoCompressorResult: Codable {
    let count: Int
    let totalSize: Int64
    let assetIDs: [String]
    let assetSizes: [String: Int64]
}

