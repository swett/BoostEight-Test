//
//  ThumbnailCell.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 10.03.2026.
//

import SwiftUI
struct ThumbnailCell: View {

    let assetID: String?
    let width: CGFloat
    let height: CGFloat

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .cornerRadius(10)
        .task(id: assetID) {
            guard let id = assetID else { return }
            image = await loadThumbnail(id: id)
        }
    }

    private func loadThumbnail(id: String) async -> UIImage? {
        await withCheckedContinuation { (continuation: CheckedContinuation<UIImage?, Never>) in
            var resumed = false
            ThumbnailManager.request(
                id: id,
                size: CGSize(width: width * UIScreen.main.scale,
                             height: height * UIScreen.main.scale)
            ) { image in
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: image)
            }
        }
    }
}
