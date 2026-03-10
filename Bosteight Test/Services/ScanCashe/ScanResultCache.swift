//
//  ScanResultCache.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 10.03.2026.
//

import Foundation
import Photos

actor ScanResultCache {

    static let shared = ScanResultCache()

    private let url: URL

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        url = caches.appendingPathComponent("scan_result.json")
    }

    // MARK: - Persist

    func save(_ result: ScanResult) {
        let codable = CodableScanResult(from: result)
        guard let data = try? JSONEncoder().encode(codable) else { return }
        try? data.write(to: url, options: .atomic)
    }

    // MARK: - Load & reconcile against live library

    func load() -> ScanResult? {
        guard
            let data = try? Data(contentsOf: url),
            let codable = try? JSONDecoder().decode(CodableScanResult.self, from: data)
        else { return nil }

        // Fetch all currently existing asset IDs from Photos
        let existingIDs = Set(fetchExistingIDs())

        return codable.toScanResult(existingIDs: existingIDs)
    }

    func clear() {
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Private

    private func fetchExistingIDs() -> [String] {
        let result = PHAsset.fetchAssets(with: nil)
        var ids: [String] = []
        ids.reserveCapacity(result.count)
        result.enumerateObjects { asset, _, _ in ids.append(asset.localIdentifier) }
        return ids
    }
}
