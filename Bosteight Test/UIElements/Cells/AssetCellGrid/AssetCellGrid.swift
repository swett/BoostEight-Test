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

    var body: some View {

        ZStack(alignment: .topTrailing) {

            AssetThumbnailView(
                id: asset.id,
                size: CGSize(width: 177, height: 216)
            )
            .frame(width: 177, height: 216)
            .clipped()

            CheckBoxView(isSelected: asset.isSelected)
                .padding(6)
        }
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    AssetCellGrid(asset: SelectableAsset(id: "", size: 0, isSelected: false, isBest: true), onTap: {})
}
