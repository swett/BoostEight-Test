//
//  CategoryCard.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 03.03.2026.
//

import SwiftUI

struct CategoryCard: View {

    let type: CategoryType
    let countText: String
    let previewAssetIDs: [String]  // ← pass IDs, not images
    let state: CategoryState
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Image(type.iconName)
                Text(type.title)
                    .font(.sfSemiBold20)
                    .foregroundStyle(Color.theme.color2B2B2B)
                Spacer()
                if state == .locked {
                    Image("lock_icon")
                }
            }

            Text(countText)
                .font(.sfRegular16)
                .foregroundStyle(Color.theme.color636363)

            previewSection
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .onTapGesture { action() }
    }
}

#Preview {
    CategoryCard(type: .videoCompressor, countText: "12267 Media • 54.7 GB", previewAssetIDs: [], state: .locked, action: {})
}


private extension CategoryCard {

    @ViewBuilder
    var previewSection: some View {
        switch state {

        case .locked:
            lockedPlaceholder

        case .loading:
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                ProgressView()
            }
            .frame(height: 155)

        case .ready:
            readyPreview
        }
    }

    @ViewBuilder
    var lockedPlaceholder: some View {
        if type == .videoCompressor {
            Image("locked_placeholder_compressor")
                .resizable()
                .scaledToFill()
                .frame(width: 336, height: 155)
                .clipped()
                .cornerRadius(10)
        } else {
            HStack(spacing: 8) {
                Image("locked_placeholder_media_0")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 164, height: 155)
                    .clipped()
                    .cornerRadius(10)
                Image("locked_placeholder_media_1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 164, height: 155)
                    .clipped()
                    .cornerRadius(10)
            }
        }
    }

    @ViewBuilder
    var readyPreview: some View {
        if type == .videoCompressor {
            // Single wide thumbnail
            ThumbnailCell(
                assetID: previewAssetIDs.first,
                width: 336,
                height: 155
            )
        } else {
            // Two thumbnails side by side
            HStack(spacing: 8) {
                ForEach(previewAssetIDs.prefix(2), id: \.self) { id in
                    ThumbnailCell(assetID: id, width: 164, height: 155)
                }
            }
        }
    }
}
