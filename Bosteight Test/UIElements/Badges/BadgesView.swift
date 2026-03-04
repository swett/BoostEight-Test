//
//  BadgesView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import SwiftUI

struct BadgesView: View {
    var iconName: String
    var text: String
    var body: some View {
        HStack {
            Image(iconName)
                .foregroundStyle(Color.theme.color1F1F1F)
            Text(text)
                .font(.sfRegular14)
                .foregroundStyle(Color.theme.color8E8E8E)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7.5)
        .background {
            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(Color.theme.colorFFFFFF)
                .shadow(color: Color.theme.color2B2B2B.opacity(0.22),radius: 4.9)
        }
    }
}

#Preview {
    BadgesView(iconName: "video_icon_black", text: "1111")
}
