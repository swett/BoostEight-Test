//
//  MainViewModel.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 03.03.2026.
//

import Foundation
import Photos
import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {

    // MARK: - Dependencies
    private let router: Routing?
    private let scanner: MediaScanner
    private let scanStore: ScanStore          // ← injected, shared instance

    // MARK: - Published
    @Published var accessState: LibraryAccessState = .notDetermined
    @Published var storageTitle: String = "iPhone Storage"
    @Published var storageUsedFormatted: String = ""
    @Published var storageTotalFormatted: String = ""
    @Published var storageProgress: Double = 0
    @Published var mediaPreviewImages: [UIImage] = []
    @Published var videoPreviewImages: [UIImage] = []
    @Published var showPermissionAlert: Bool = false
    @Published var isScanning: Bool = false

    // Derived from scanStore — always in sync
    var mediaCount: Int   { scanStore.scanResult.totalCount }
    var mediaSize: Int64  { scanStore.scanResult.totalSize }
    var videoCount: Int   { scanStore.scanResult.videoCompressor.count }
    var videoSize: Int64  { scanStore.scanResult.videoCompressor.totalSize }

    var videoCategoryState: CategoryState {
        switch accessState {
        case .denied, .notDetermined: return .locked
        case .authorized, .limited:   return isScanning ? .loading : .ready
        }
    }

    var mediaCategoryState: CategoryState {
        switch accessState {
        case .denied, .notDetermined: return .locked
        case .authorized, .limited:   return isScanning ? .loading : .ready
        }
    }

    private var scanTask: Task<Void, Never>?

    // MARK: - Init
    init(
        router: Routing? = nil,
        scanner: MediaScanner,
        scanStore: ScanStore                  // ← injected
    ) {
        self.router = router
        self.scanner = scanner
        self.scanStore = scanStore

        updateDeviceStorage()
        checkPermission()
    }
}

// MARK: - Scan (writes into ScanStore)

extension MainViewModel {

    private func startScan() {
        isScanning = true
        scanTask?.cancel()

        scanTask = Task {
            for await (_, result) in await scanner.scan() {
                if let result {
                    scanStore.apply(result)     // store is the single source of truth
                    isScanning = false
                    loadPreviewImages()
                }
            }
        }
    }
}


extension MainViewModel {

    func openMedia() {
        handleCategoryTap { router?.push(.mediaHome) }
    }

    func openVideoCompressor() {
        handleCategoryTap { router?.push(.videoCompressorList) }
    }

    private func handleCategoryTap(action: () -> Void) {
        switch accessState {
        case .authorized, .limited:   action()
        case .notDetermined:          requestPermission()
        case .denied:                 showPermissionAlert = true
        }
    }
    
    func requestPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            Task { @MainActor in
                self?.handleAuthorization(status)
            }
        }
    }
    
    private func handleAuthorization(_ status: PHAuthorizationStatus) {
    
            switch status {
            case .authorized:
                accessState = .authorized
                startScan()
    
            case .limited:
                accessState = .limited
                startScan()
    
            case .denied, .restricted:
                accessState = .denied
    
            default:
                accessState = .denied
            }
        }
}

extension MainViewModel {
    private func updateDeviceStorage() {
        
        do {
            let values = try URL(fileURLWithPath: NSHomeDirectory())
                .resourceValues(forKeys: [
                    .volumeAvailableCapacityForImportantUsageKey,
                    .volumeTotalCapacityKey
                ])
            
            guard
                let total = values.volumeTotalCapacity,
                let available = values.volumeAvailableCapacityForImportantUsage
            else { return }
            
            let used = Int64(total) - available
            
            storageProgress = Double(used) / Double(total)
            
            storageUsedFormatted = formatBytes(used)
            storageTotalFormatted = formatBytes(Int64(total))
            
        } catch {
            storageProgress = 0
        }
    }
    
    func checkPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            accessState = .notDetermined
            
        case .authorized:
            accessState = .authorized
            startScan()
            
        case .limited:
            accessState = .limited
            startScan()
            
        case .denied, .restricted:
            accessState = .denied
            
        @unknown default:
            accessState = .denied
        }
    }
}


extension MainViewModel {

    func loadPreviewImages() {
        Task {
            async let media = fetchThumbnails(
                from: Array(scanStore.scanResult.media.screenshots.allAssets.prefix(6))
                    + Array(scanStore.scanResult.media.duplicatePhotos.allAssets.prefix(6))
            )
            async let videos = fetchThumbnails(
                from: Array(scanStore.scanResult.videoCompressor.assets.prefix(6))
            )

            let (mediaImages, videoImages) = await (media, videos)
            mediaPreviewImages = mediaImages
            videoPreviewImages = videoImages
        }
    }

    private func fetchThumbnails(from assets: [PHAsset]) async -> [UIImage] {

        let targetSize = CGSize(width: 160, height: 160)

        var seen = Set<String>()
        let unique = assets.filter { seen.insert($0.localIdentifier).inserted }

        return await withTaskGroup(of: (Int, UIImage?).self) { group in

            for (index, asset) in unique.prefix(6).enumerated() {
                group.addTask {
                    let image = await withCheckedContinuation { (continuation: CheckedContinuation<UIImage?, Never>) in

                        var resumed = false   // ← guard against double-resume

                        ThumbnailManager.request(
                            id: asset.localIdentifier,
                            size: targetSize
                        ) { image in
                            guard !resumed else { return }
                            resumed = true
                            continuation.resume(returning: image)
                        }
                    }
                    return (index, image)
                }
            }

            var results: [(Int, UIImage)] = []
            for await (index, image) in group {
                if let image { results.append((index, image)) }
            }

            return results
                .sorted { $0.0 < $1.0 }
                .map(\.1)
        }
    }
}
