//
//  CategoryType.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 03.03.2026.
//

import Foundation

enum MediaSubcategory: Hashable {
    case screenshots, livePhotos, screenRecordings
    case duplicatePhotos, similarPhotos, similarVideos
    
    var title: String {
        switch self {
        case .screenshots:      return "Screenshots"
        case .livePhotos:       return "Live Photos"
        case .screenRecordings: return "Screen Recordings"
        case .duplicatePhotos:  return "Duplicate Photos"
        case .similarPhotos:    return "Similar Photos"
        case .similarVideos:    return "Similar Videos"
        }
    }
    
    // All subcategories share the same icon — no switch needed
    var iconName: String {
        switch self {
        case .screenshots:
            return "screenshots_icon"
        case .livePhotos:
            return "live_photos_icon"
        case .screenRecordings:
            return "screen_recordings_icon"
        case .duplicatePhotos:
            return "duplicate_photos_icon"
        case .similarPhotos:
            return "similar_photos_icon"
        case .similarVideos:
            return "similar_photos_icon"
        }
    }
    
    
    
    var screenType: MediaCategoryScreenType {
        switch self {
        case .duplicatePhotos,
                .similarPhotos,
                .similarVideos:
            return .grouped
            
        case .livePhotos,
                .screenshots,
                .screenRecordings:
            return .grid
        }
    }
    
}

enum CategoryType: Equatable {
    case videoCompressor
    case media(MediaSubcategory?)
    
    var title: String {
        switch self {
        case .videoCompressor:      return "Video Compressor"
        case .media(let sub):       return sub?.title ?? "Media"
        }
    }
    
    var iconName: String {
        switch self {
        case .videoCompressor:      return "video_icon"
        case .media(let sub):       return sub?.iconName ?? "media_icon"
        }
    }
}
