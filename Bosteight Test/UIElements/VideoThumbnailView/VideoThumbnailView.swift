//
//  VideoThumbnailView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import SwiftUI
import Photos

struct VideoThumbnailView: View {
    let asset: PHAsset
    let height: CGFloat

    @State private var thumbnail: UIImage?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.15))

            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                Image(systemName: "video.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .task {
            thumbnail = await loadThumbnail()
        }
    }

    private func loadThumbnail() async -> UIImage? {
        await withCheckedContinuation { continuation in
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false

            let targetSize = CGSize(
                width: UIScreen.main.bounds.width * UIScreen.main.scale,
                height: height * UIScreen.main.scale
            )

            manager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
