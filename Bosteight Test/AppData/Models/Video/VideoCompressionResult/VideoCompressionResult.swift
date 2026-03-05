//
//  VideoCompressionResult.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import Foundation
import Photos
struct VideoCompressionResult {

    let originalAsset: PHAsset

    let compressedURL: URL

    let originalSize: Int64

    let compressedSize: Int64
}
