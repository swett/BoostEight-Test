//
//  PhotoLibraryService.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation
import Photos

protocol PhotoLibraryServiceProtocol {
    func deleteAssets(ids: [String]) async throws
}

final class PhotoLibraryService: PhotoLibraryServiceProtocol {

    func deleteAssets(ids: [String]) async throws {

        let fetchResult = PHAsset.fetchAssets(
            withLocalIdentifiers: ids,
            options: nil
        )

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets(fetchResult)
        }
    }
}
