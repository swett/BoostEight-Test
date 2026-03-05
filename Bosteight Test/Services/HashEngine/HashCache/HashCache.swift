//
//  HashCache.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import Foundation

actor HashCache {

    static let shared = HashCache()

    private var cache: [String: UInt64] = [:]

    private let url: URL

    init() {

        let folder = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!

        url = folder.appendingPathComponent("photo_hash_cache.json")

        load()
    }

    func hash(for id: String) -> UInt64? {
        cache[id]
    }

    func save(hash: UInt64, for id: String) {
        cache[id] = hash
    }

    func persist() {
        guard let data = try? JSONEncoder().encode(cache) else { return }
        try? data.write(to: url)
    }

    private func load() {

        guard let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: UInt64].self, from: data)
        else { return }

        cache = decoded
    }
}
