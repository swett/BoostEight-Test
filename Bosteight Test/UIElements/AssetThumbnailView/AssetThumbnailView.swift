//
//  AssetThumbnailView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 06.03.2026.
//

import SwiftUI

struct AssetThumbnailView: View {

    let id: String
    let size: CGSize

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .task(id: id) {
            image = await loadThumbnail()
        }
    }

    private func loadThumbnail() async -> UIImage? {
        await withCheckedContinuation { (continuation: CheckedContinuation<UIImage?, Never>) in
            var resumed = false
            ThumbnailManager.request(id: id, size: size) { image in
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: image)
            }
        }
    }
}
