//
//  VideoCompressionServiceProtocol.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import Photos

protocol VideoCompressionServiceProtocol {
    
    func compress(
        asset: PHAsset,
        quality: VideoCompressionQuality
    ) -> AsyncStream<VideoCompressionState>
    
    func cancel()
    
    func saveCompressedVideo(from url: URL) async throws
    
    func deleteOriginal(asset: PHAsset) async throws
    
    func keepBoth(
        compressedURL: URL,
        original: PHAsset
    ) async throws
    
    func loadAVAsset(for asset: PHAsset) async -> AVAsset?
}
