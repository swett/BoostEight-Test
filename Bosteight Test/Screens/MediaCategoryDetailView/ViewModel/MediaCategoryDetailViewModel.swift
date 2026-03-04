//
//  MediaCategoryDetailViewModel.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation
import Photos

@MainActor
final class MediaCategoryDetailViewModel: ObservableObject {

    private let router: Routing?
    private let subcategory: MediaSubcategory
    private let scanStore: ScanStoreProtocol
    private let photoService: PhotoLibraryServiceProtocol

    let screenType: MediaCategoryScreenType

    @Published var groups: [AssetGroup] = []
    @Published var gridAssets: [SelectableAsset] = []

    @Published var selectedCount: Int = 0
    @Published var selectedSize: Int64 = 0
    @Published var showDeleteAlert: Bool = false
    
    var countOfFiles: String {
        let category = scanStore.category(for: subcategory)
        return "\(category.count)"
    }
    
    var sizeOfFiles: String {
        let category = scanStore.category(for: subcategory)
        return "\(formatBytes(category.totalSize))"
    }

    init(
        router: Routing? = nil,
        subcategory: MediaSubcategory,
        scanStore: ScanStoreProtocol,
        photoService: PhotoLibraryServiceProtocol
    ) {
        self.router = router
        self.subcategory = subcategory
        self.scanStore = scanStore
        self.photoService = photoService
        self.screenType = subcategory.screenType

        buildData()
    }

    
    func buildData() {
            switch screenType {
            case .grid:
                buildGrid()
            case .grouped:
                buildGrouped()
            }
        }
    
    
    private func buildGrid() {

        let category = scanStore.category(for: subcategory)

        gridAssets = category.allAssets.map {
            SelectableAsset(
                id: $0.localIdentifier,
                size: category.assetSizes[$0.localIdentifier] ?? 0,
                isSelected: false,
                isBest: false
            )
        }    }
    
    private func bestAsset(in group: [PHAsset]) -> PHAsset? {

        group.max {
            ($0.pixelWidth * $0.pixelHeight)
            < ($1.pixelWidth * $1.pixelHeight)
        }
    }

    private func buildGrouped() {

        let grouped = scanStore.groupedAssets(for: subcategory)

        groups = grouped.map { group in

            guard let best = bestAsset(in: group) else {
                return AssetGroup(id: UUID(), assets: [])
            }

            let mapped = group.map { asset in
                SelectableAsset(
                    id: asset.localIdentifier,
                    size: 0,
                    isSelected: asset.localIdentifier != best.localIdentifier,
                    isBest: asset.localIdentifier == best.localIdentifier
                )
            }

            return AssetGroup(id: UUID(), assets: mapped)
        }
    }
    
    func toggleSelection(id: String) {
        
        switch screenType {
            
        case .grid:
            guard let index = gridAssets.firstIndex(where: { $0.id == id }) else { return }
            gridAssets[index].isSelected.toggle()
            
        case .grouped:
            for groupIndex in groups.indices {
                if let assetIndex = groups[groupIndex].assets.firstIndex(where: { $0.id == id }) {
                    groups[groupIndex].assets[assetIndex].isSelected.toggle()
                }
            }
        }
        
        recalculateSelection()
    }
    
    func recalculateSelection() {
        
        let allAssets: [SelectableAsset] = {
            switch screenType {
            case .grid:
                return gridAssets
            case .grouped:
                return groups.flatMap { $0.assets }
            }
        }()
        
        let selected = allAssets.filter { $0.isSelected }
        
        selectedCount = selected.count
        selectedSize = selected.reduce(0) { $0 + $1.size }
    }
    
    func deleteTapped() {
        showDeleteAlert = true
    }
    
    func confirmDelete() {

        Task {

            let ids = selectedAssetIDs()

            do {
                try await photoService.deleteAssets(ids: ids)
                scanStore.refreshAfterDeletion(ids: ids)
                
            } catch {
                // обработка
            }
        }
    }
    func selectedAssetIDs() -> [String] {
        
        switch screenType {
        case .grid:
            return gridAssets
                .filter { $0.isSelected }
                .map { $0.id }
                
        case .grouped:
            return groups
                .flatMap { $0.assets }
                .filter { $0.isSelected }
                .map { $0.id }
        }
    }
    
    func popBack() {
        router?.popLast()
    }
}

