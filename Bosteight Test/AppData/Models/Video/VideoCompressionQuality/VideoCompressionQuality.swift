//
//  VideoCompressionQuality.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import Foundation
import AVKit

enum VideoCompressionQuality: CaseIterable {

    case low
    case medium
    case high

    var title: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var preset: String {
            switch self {
            case .low:
                return AVAssetExportPresetLowQuality
            case .medium:
                return AVAssetExportPresetMediumQuality
            case .high:
                return AVAssetExportPresetHighestQuality
            }
        }

    
    var videoBitrate: Double {
            switch self {
            case .low:
                return 1_000_000      // 1 Mbps
            case .medium:
                return 2_500_000      // 2.5 Mbps
            case .high:
                return 5_000_000      // 5 Mbps
            }
        }
}
extension VideoCompressionQuality {

    func estimatedSize(from original: Int64) -> Int64 {

        switch self {
        case .low:
            return Int64(Double(original) * 0.25)

        case .medium:
            return Int64(Double(original) * 0.45)

        case .high:
            return Int64(Double(original) * 0.65)
        }
    }
    
    
}
