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
//    #if DEBUG
//       Rectangle()
//           .fill(Color.gray.opacity(0.3))
//           .overlay(
//               Text(id.prefix(4))
//                   .font(.caption)
//           )
//       #else
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
//#endif
    }
}
