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
