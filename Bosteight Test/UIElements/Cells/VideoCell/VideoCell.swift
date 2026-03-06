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

    // Calculate column width once: (screenWidth - horizontal padding - spacing) / 2
    private var cellWidth: CGFloat {
        (UIScreen.main.bounds.width - 16 * 2 - 12) / 2
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            PHAssetThumbnailView(
                asset: asset,
                targetSize: CGSize(width: cellWidth, height: 176)
            )
            .frame(width: cellWidth, height: 176)
            .clipped()

            Text(sizeText)
                .font(.sfRegular14)
                .foregroundStyle(Color.theme.colorFFFFFF)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(Color.theme.color495AE9)
                }
                .padding(6)
        }
        .frame(width: cellWidth, height: 176)
        .cornerRadius(10)
        .clipped()
        .contentShape(Rectangle())  // tap area matches visible frame exactly
    }
}

#Preview {
    VideoCell(asset: PHAsset(), sizeText: "1.2 GB")
}
