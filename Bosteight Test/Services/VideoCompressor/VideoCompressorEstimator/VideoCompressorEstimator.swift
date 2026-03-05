//
//  VideoCompressorEstimator.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import Foundation
import AVFoundation

final class VideoCompressionEstimator {
    
    func estimateSize(
        asset: AVAsset,
        quality: VideoCompressionQuality
    ) async -> Int64 {
        
        let duration = CMTimeGetSeconds(asset.duration)
        
        guard duration > 0 else { return 0 }
        
        let audioBitrate = await extractAudioBitrate(asset)
        let videoBitrate = quality.videoBitrate
        
        let totalBitrate = videoBitrate + audioBitrate
        
        let estimatedBits = totalBitrate * duration
        
        return Int64(estimatedBits / 8)
    }
    
    private func extractAudioBitrate(_ asset: AVAsset) async -> Double {
        
        guard let track = try? await asset.loadTracks(withMediaType: .audio).first else {
            return 128_000
        }
        
        let formatDescriptions = try? await track.load(.formatDescriptions)
        
        guard
            let desc = formatDescriptions?.first,
            let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(desc as! CMAudioFormatDescription)
        else {
            return 128_000
        }
        
        return Double(Double(asbd.pointee.mBitsPerChannel) * asbd.pointee.mSampleRate)
    }
}
