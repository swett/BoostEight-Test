//
//  VideoCell.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import SwiftUI
import Photos

struct VideoCell: View {

    let asset: PHAsset
    let sizeText: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            PHAssetThumbnailView(asset: asset)
                .frame(height: 150)
                .cornerRadius(10)
                .clipped()

            Text(sizeText)
                .font(.sfRegular14)
                .foregroundStyle(Color.theme.colorFFFFFF)
                .padding(4)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(Color.theme.color495AE9)
                }
        }
    }
}

#Preview {
    VideoCell(asset: PHAsset(), sizeText: "1.2 GB")
}
