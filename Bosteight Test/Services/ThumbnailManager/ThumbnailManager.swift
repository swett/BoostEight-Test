//
//  ThumbnailManager.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import Foundation
import Photos
import SwiftUI
final class ThumbnailManager {

    static let shared = PHCachingImageManager()

    static func request(
        id: String,
        size: CGSize,
        completion: @escaping (UIImage?) -> Void
    ) {

        let result = PHAsset.fetchAssets(
            withLocalIdentifiers: [id],
            options: nil
        )

        guard let asset = result.firstObject else {
            completion(nil)
            return
        }

        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = false

        shared.requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            completion(image)
        }
    }
}

struct AssetThumbnailView: View {

    let id: String
    let size: CGSize

    @State private var image: UIImage?

    var body: some View {
    #if DEBUG
       Rectangle()
           .fill(Color.gray.opacity(0.3))
           .overlay(
               Text(id.prefix(4))
                   .font(.caption)
           )
       #else
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .onAppear {
            ThumbnailManager.request(
                id: id,
                size: size
            ) { image in
                self.image = image
            }
        }
#endif
    }
}
