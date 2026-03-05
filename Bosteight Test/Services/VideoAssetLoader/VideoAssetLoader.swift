//
//  VideoAssetLoader.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import Photos
import AVFoundation

final class VideoAssetLoader {
    
    func loadAVAsset(_ asset: PHAsset) async throws -> AVAsset {
        
        try await withCheckedThrowingContinuation { continuation in
            
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
            
            PHImageManager.default().requestAVAsset(
                forVideo: asset,
                options: options
            ) { avAsset, _, info in
                
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let avAsset else {
                    continuation.resume(throwing: NSError(domain: "VideoAssetLoader", code: -1))
                    return
                }
                
                continuation.resume(returning: avAsset)
            }
        }
    }
}
