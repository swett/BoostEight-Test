//
//  MockPhotoLibraryService.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation

final class MockPhotoLibraryService: PhotoLibraryServiceProtocol {
    func deleteAssets(ids: [String]) async throws {}
}
