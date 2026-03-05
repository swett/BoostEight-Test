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

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {

        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 300, height: 300),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            uiView.image = image
        }
    }
}