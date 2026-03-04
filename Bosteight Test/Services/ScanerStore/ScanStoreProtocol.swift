//
//  ScanStoreProtocol.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation
import Photos
@MainActor
protocol ScanStoreProtocol: ObservableObject {
    
    var scanResult: ScanResult { get }
    
    func category(for subcategory: MediaSubcategory) -> MediaCategory
    
    func groupedAssets(for subcategory: MediaSubcategory) -> [[PHAsset]]
    
    func deleteAssets(ids: [String]) async throws
    
    func refreshAfterDeletion(ids: [String])
}
