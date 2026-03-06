//
//  ThumbnailManager.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation
import Photos
import SwiftUI
final class ThumbnailManager {

    static let shared = PHCachingImageManager()

    static func request(
        id: String,
        size: CGSize,
        completion: @escaping (UIImage?) -> Void
    ) {
        
        let result = PHAsset.fetchAssets(
            withLocalIdentifiers: [id],
            options: nil
        )
        
        guard let asset = result.firstObject else {
            completion(nil)
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = false
        
        shared.requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        ) { image, info in
            let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
            guard !isDegraded else { return }   // ← only deliver final result
            completion(image)
        }
    }
}

