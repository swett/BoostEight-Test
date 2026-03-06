//
//  PHAssetThumbnailView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//


import SwiftUI
import PhotosUI

struct PHAssetThumbnailView: UIViewRepresentable {

    let asset: PHAsset
    let targetSize: CGSize

    init(asset: PHAsset, targetSize: CGSize = CGSize(width: 500, height: 500)) {
        self.asset = asset
        self.targetSize = targetSize
    }

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        guard context.coordinator.currentIdentifier != asset.localIdentifier else { return }
        context.coordinator.currentIdentifier = asset.localIdentifier
        context.coordinator.cancelCurrentRequest(in: uiView)
        loadImage(into: uiView, context: context)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    private func loadImage(into uiView: UIImageView, context: Context) {

        let scale = UIScreen.main.scale
        let pixelSize = CGSize(
            width: targetSize.width * scale,
            height: targetSize.height * scale
        )

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat   // crisp final image
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        options.isNetworkAccessAllowed = true

        let requestID = PHImageManager.default().requestImage(
            for: asset,
            targetSize: pixelSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            guard let image else { return }
            DispatchQueue.main.async { uiView.image = image }
        }

        context.coordinator.requestID = requestID
    }
}

// MARK: - Coordinator

extension PHAssetThumbnailView {
    final class Coordinator {
        var requestID: PHImageRequestID?
        var currentIdentifier: String?

        func cancelCurrentRequest(in uiView: UIImageView) {
            if let id = requestID {
                PHImageManager.default().cancelImageRequest(id)
                requestID = nil
            }
            uiView.image = nil
        }
    }
}
