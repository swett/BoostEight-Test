//
//  VideoCompressorDetailViewModel.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import Foundation
import Photos
import AVKit
@MainActor
final class VideoCompressorDetailViewModel: ObservableObject {

    // MARK: - Dependencies
    private let assetID: String
    private let router: Routing?
    private let scanStore: ScanStoreProtocol
    private let compressionService: VideoCompressionServiceProtocol
    private let estimator: VideoCompressionEstimator
    private let assetLoader: VideoAssetLoader = VideoAssetLoader()
    // MARK: - Published State
    @Published var asset: PHAsset?
    @Published var originalSize: Int64 = 0
    @Published var selectedQuality: VideoCompressionQuality = .medium
    @Published var estimatedSize: Int64 = 0
    @Published var compressionState: VideoCompressionState = .idle
    @Published var showPostCompressionSheet: Bool = false

    private var compressionResult: VideoCompressionResult?
    private var avAsset: AVAsset?

    // MARK: - Init
    init(
        assetID: String,
        router: Routing?,
        scanStore: ScanStoreProtocol,
        compressionService: VideoCompressionServiceProtocol,
        estimator: VideoCompressionEstimator
    ) {
        self.assetID = assetID
        self.router = router
        self.scanStore = scanStore
        self.compressionService = compressionService
        self.estimator = estimator

        loadAsset()
    }

    // MARK: - Load
    private func loadAsset() {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil)
        guard let asset = result.firstObject else { return }
        self.asset = asset

        // Original size from scanStore's assetSizes map
        self.originalSize = scanStore.scanResult.videoCompressor.assetSizes[assetID] ?? 0

        Task {
            await loadAVAssetAndEstimate()
        }
    }

    private func loadAVAssetAndEstimate() async {
        guard let asset else { return }

        let avAsset = await compressionService.loadAVAsset(for: asset)
        self.avAsset = avAsset
        await updateEstimate()
    }

    // MARK: - Quality Selection
    func selectQuality(_ quality: VideoCompressionQuality) {
        selectedQuality = quality
        Task { await updateEstimate() }
    }

    private func updateEstimate() async {
        if let avAsset {
            estimatedSize = await estimator.estimateSize(asset: avAsset, quality: selectedQuality)
        } else {
            // Fallback to ratio-based estimate when AVAsset isn't loaded yet
            estimatedSize = selectedQuality.estimatedSize(from: originalSize)
        }
    }

    // MARK: - Compression
    func startCompression() {
        guard let asset, case .idle = compressionState else { return }

        Task {
            for await state in compressionService.compress(asset: asset, quality: selectedQuality) {
                compressionState = state

                if case .finished(let result) = state {
                    compressionResult = result
                    showPostCompressionSheet = true
                }
            }
        }
    }

    func cancelCompression() {
        compressionService.cancel()
        compressionState = .idle
    }

    // MARK: - Post-Compression Actions
    func saveAndDeleteOriginal() async {
        guard let result = compressionResult, let asset else { return }
        do {
            try await compressionService.saveCompressedVideo(from: result.compressedURL)
            try await compressionService.deleteOriginal(asset: asset)
            scanStore.refreshAfterDeletion(ids: [assetID])
            router?.popLast()
        } catch {
            compressionState = .failed(error)
        }
    }

    func keepBoth() async {
        guard let result = compressionResult, let asset else { return }
        do {
            try await compressionService.keepBoth(compressedURL: result.compressedURL, original: asset)
            router?.popLast()
        } catch {
            compressionState = .failed(error)
        }
    }

    // MARK: - Helpers
    func popBack() {
        compressionService.cancel()
        router?.popLast()
    }

    var compressionProgress: Double {
        if case .compressing(let p) = compressionState { return p }
        return 0
    }

    var isCompressing: Bool {
        if case .compressing = compressionState { return true }
        if case .preparing = compressionState { return true }
        return false
    }

    var isFinished: Bool {
        if case .finished = compressionState { return true }
        return false
    }

    var savedSize: Int64 {
        guard let result = compressionResult else { return 0 }
        return max(0, result.originalSize - result.compressedSize)
    }

    var actualCompressedSize: Int64 {
        compressionResult?.compressedSize ?? estimatedSize
    }

    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}


// MARK: - Mock service for preview
final class MockVideoCompressionService: VideoCompressionServiceProtocol {
    func compress(asset: PHAsset, quality: VideoCompressionQuality) -> AsyncStream<VideoCompressionState> {
        AsyncStream { continuation in
            Task {
                continuation.yield(.preparing)
                try? await Task.sleep(nanoseconds: 500_000_000)
                for i in 1...5 {
                    continuation.yield(.compressing(progress: Double(i) / 5.0))
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
                continuation.finish()
            }
        }
    }
    func cancel() {}
    func saveCompressedVideo(from url: URL) async throws {}
    func deleteOriginal(asset: PHAsset) async throws {}
    func keepBoth(compressedURL: URL, original: PHAsset) async throws {}
    func loadAVAsset(for asset: PHAsset) async -> AVAsset? { nil }
}
