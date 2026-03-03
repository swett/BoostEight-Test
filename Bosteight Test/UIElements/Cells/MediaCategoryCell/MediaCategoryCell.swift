//
//  MediaCategoryCell.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 03.03.2026.
//

import SwiftUI

struct MediaCategoryCell: View {
    var model: MediaHomeItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(model.id.iconName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .cornerRadius(100, corners: .allCorners)
                Spacer()
            }
            Spacer()
            VStack(alignment: .leading, spacing: 6) {
                Text(model.id.title)
                    .font(.sfMedium16)
                    .foregroundStyle(Color.theme.color1F1F1F)
                    .padding(.top, 21)
                Text("\(model.count) items")
                    .font(.sfRegular14)
                    .foregroundStyle(Color.theme.color8E8E8E)
                    
            }
        }
        .padding(.all, 13)
        .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 130)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.theme.colorFFFFFF)
                .shadow(color: Color.theme.color2B2B2B.opacity(0.15), radius: 8.3)
        }
    }
}

#Preview {
    MediaCategoryCell(model: MediaHomeItem(id: .livePhotos, title: "", count: 1000, totalSize: 3000, previewAssetIDs: []))
}
