//
//  VideoCompressorListViewModel.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import SwiftUI
import Photos

@MainActor
final class VideoCompressorListViewModel: ObservableObject {

    private let router: Routing?
    private let scanStore: ScanStoreProtocol

    @Published var assets: [PHAsset] = []
    @Published var assetSizes: [String: Int64] = [:]

    init(
        router: Routing? = nil,
        scanStore: ScanStoreProtocol
    ) {
        self.router = router
        self.scanStore = scanStore

        loadAssets()
    }

    private func loadAssets() {
        let result: VideoCompressorResult = scanStore.scanResult.videoCompressor
        self.assets = result.assets
        self.assetSizes = result.assetSizes
    }

    var countText: String {
        "\(assets.count) videos"
    }

    func sizeText(for asset: PHAsset) -> String {
        guard let size = assetSizes[asset.localIdentifier] else { return "--" }
        return formatBytes(size)
    }

    func didTapAsset(_ asset: PHAsset) {
        router?.push(
            .videoCompressorDetail(assetID: asset.localIdentifier)
        )
    }
    
    func popBack() {
        router?.popLast()
    }

    // Helper
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}


@MainActor
final class MockVideoCompressorListViewModel: ObservableObject {
    
    // Simulate rows using just IDs + sizes (no real PHAsset needed)
    struct MockVideoItem: Identifiable {
        let id: String
        let sizeText: String
    }

    let items: [MockVideoItem] = {
        let sizes: [(String, Int64)] = [
            ("MOCK-VIDEO-001", 85_000_000),
            ("MOCK-VIDEO-002", 210_000_000),
            ("MOCK-VIDEO-003", 45_500_000),
            ("MOCK-VIDEO-004", 512_000_000),
            ("MOCK-VIDEO-005", 128_000_000),
            ("MOCK-VIDEO-006", 1_073_741_824)
        ]
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return sizes.map {
            MockVideoItem(id: $0.0, sizeText: formatter.string(fromByteCount: $0.1))
        }
    }()

    var countText: String { "\(items.count) videos" }
}
