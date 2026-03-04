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
    
    // MARK: - Published
    
    @Published var accessState: LibraryAccessState = .notDetermined
    
    @Published var storageTitle: String = "iPhone Storage"
    @Published var storageUsedFormatted: String = ""
    @Published var storageTotalFormatted: String = ""
    @Published var storageProgress: Double = 0
    
    @Published var mediaPreviewImages: [UIImage] = []
    @Published var videoPreviewImages: [UIImage] = []
    
    @Published var mediaCount: Int = 0
    @Published var mediaSize: Int64 = 0
    
    @Published var videoCount: Int = 0
    @Published var videoSize: Int64 = 0
    
    @Published var showPermissionAlert: Bool = false
    
    @Published var isScanning: Bool = false
    
    var videoCategoryState: CategoryState {
        switch accessState {
        case .denied, .notDetermined:
            return .locked
        case .authorized, .limited:
            return isScanning ? .loading : .ready
        }
    }

    var mediaCategoryState: CategoryState {
        switch accessState {
        case .denied, .notDetermined:
            return .locked
        case .authorized, .limited:
            return isScanning ? .loading : .ready
        }
    }
    
    private var scanTask: Task<Void, Never>?
    
    // MARK: - Init
    
    init(router: Routing? = nil,
         scanner: MediaScanner) {
        self.router = router
        self.scanner = scanner
        
        updateDeviceStorage()
        checkPermission()
    }
}


extension MainViewModel {
    
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
    
    private func startScan() {
        isScanning = true
        scanTask?.cancel()
        
        scanTask = Task {
            
            for await (progress, result) in await scanner.scan() {
                
                if let result {
                    apply(result)
                }
            }
        }
    }
    
    private func apply(_ result: ScanResult) {
        
        mediaCount = result.totalCount
        mediaSize = result.totalSize
        
        videoCount = result.videoCompressor.count
        videoSize = result.videoCompressor.totalSize
        isScanning = false
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
}


extension MainViewModel {
    
    func openMedia() {
        handleCategoryTap {
            router?.push(.mediaHome)
        }
    }
    
    func openVideoCompressor() {
        handleCategoryTap {
            router?.push(.videoCompressorList)
        }
    }
    
    private func handleCategoryTap(action: () -> Void) {
        
        switch accessState {
            
        case .authorized, .limited:
            action()
            
        case .notDetermined:
            requestPermission()
            
        case .denied:
            showPermissionAlert = true
        }
    }
}
