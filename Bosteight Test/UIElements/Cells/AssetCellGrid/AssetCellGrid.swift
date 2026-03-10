//
//  AssetCellGrid.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import SwiftUI

struct AssetCellGrid: View {

    let asset: SelectableAsset
    let onTap: () -> Void

    // Mirror grid math: (screenWidth - 16 leading - 16 trailing padding - 12 spacing) / 2
    private var cellWidth: CGFloat {
        (UIScreen.main.bounds.width - 16 * 2 - 12) / 2
    }

    private var cellHeight: CGFloat {
        cellWidth * (216.0 / 177.0)  // preserve original aspect ratio
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AssetThumbnailView(
                id: asset.id,
                size: CGSize(width: cellWidth, height: cellHeight)
            )
            .frame(width: cellWidth, height: cellHeight)
            .clipped()
            .cornerRadius(10)

            HStack {
                if asset.isBest {
                    Image("bestBage_icon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 65, height: 25)
                }
                Spacer()
                CheckBoxView(isSelected: asset.isSelected)
                    .padding(6)
            }
        }
        .frame(width: cellWidth, height: cellHeight)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}

#Preview {
    AssetCellGrid(asset: SelectableAsset(id: "", size: 0, isSelected: false, isBest: true), onTap: {})
}
