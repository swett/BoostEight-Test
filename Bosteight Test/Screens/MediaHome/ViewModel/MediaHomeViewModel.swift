//
//  MediaHomeViewModel.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 03.03.2026.
//

import Foundation
import Photos
import SwiftUI
import Combine

final class MediaHomeViewModel: MediaHomeViewModelProtocol {

    private let router: Routing
    private let scanStore: ScanStore  // ← concrete type, not protocol

    @Published var items: [MediaHomeItem] = []
    private var cancellables = Set<AnyCancellable>()

    init(router: Routing, scanStore: ScanStore) {
        self.router = router
        self.scanStore = scanStore
        buildItems()
        observeStore()
    }

    private func observeStore() {
        scanStore.$scanResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.buildItems()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Private

private extension MediaHomeViewModel {

    func buildItems() {
        let media = scanStore.scanResult.media

        items = [
            buildItem(.screenshots,     media.screenshots),
            buildItem(.livePhotos,      media.livePhotos),
            buildItem(.screenRecordings, media.screenRecordings),
            buildItem(.duplicatePhotos, media.duplicatePhotos),
            buildItem(.similarPhotos,   media.similarPhotos),
            buildItem(.similarVideos,   media.similarVideos)
        ]
        .filter { $0.count > 0 }
    }

    func buildItem(
        _ subcategory: MediaSubcategory,
        _ category: MediaCategory
    ) -> MediaHomeItem {
        MediaHomeItem(
            id: subcategory,
            title: subcategory.title,
            count: category.count,
            totalSize: category.totalSize,
            previewAssetIDs: category.allAssets
                .prefix(4)
                .map { $0.localIdentifier }
        )
    }
}

// MARK: - Navigation

extension MediaHomeViewModel {

    func openCategory(_ subcategory: MediaSubcategory) {
        router.push(.mediaCategory(subcategory))
    }

    func popBack() {
        router.popLast()
    }
}


extension MediaHomeItem {
    static let mockItems: [MediaHomeItem] = [
        .init(id: .screenshots,      title: MediaSubcategory.screenshots.title,      count: 142,  totalSize: 890_000_000,  previewAssetIDs: []),
        .init(id: .livePhotos,       title: MediaSubcategory.livePhotos.title,       count: 38,   totalSize: 210_000_000,  previewAssetIDs: []),
        .init(id: .screenRecordings, title: MediaSubcategory.screenRecordings.title, count: 17,   totalSize: 1_500_000_000, previewAssetIDs: []),
        .init(id: .duplicatePhotos,  title: MediaSubcategory.duplicatePhotos.title,  count: 54,   totalSize: 340_000_000,  previewAssetIDs: []),
        .init(id: .similarPhotos,    title: MediaSubcategory.similarPhotos.title,    count: 91,   totalSize: 560_000_000,  previewAssetIDs: []),
        .init(id: .similarVideos,    title: MediaSubcategory.similarVideos.title,    count: 6,    totalSize: 750_000_000,  previewAssetIDs: [])
    ]
}

final class MockMediaHomeViewModel: MediaHomeViewModelProtocol {
    
    @Published var items: [MediaHomeItem] = MediaHomeItem.mockItems
    
    func openCategory(_ subcategory: MediaSubcategory) { }
    
    func popBack() { }
}


@MainActor
protocol MediaHomeViewModelProtocol: ObservableObject {
    var items: [MediaHomeItem] { get }
    
    func openCategory(_ subcategory: MediaSubcategory)
    func popBack()
}
