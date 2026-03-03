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
    let previewImages: [UIImage]   // ← массив
    let state: CategoryState
    let action: () -> Void
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: Header
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
            
            // MARK: Count
            Text(countText)
                .font(.sfRegular16)
                .foregroundStyle(Color.theme.color636363)
            
            // MARK: Preview
            previewSection
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    CategoryCard(type: .videoCompressor, countText: "12267 Media • 54.7 GB", previewImages: [], state: .locked, action: {})
}


private extension CategoryCard {
    
    @ViewBuilder
    var previewSection: some View {
        
        switch state {
            
        case .locked:
            Image("locked_placeholder")
                .resizable()
                .scaledToFill()
                .frame(height: 155)
                .clipped()
                .cornerRadius(10)
            
        case .loading:
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                ProgressView()
            }
            .frame(height: 120)
            
        case .ready:
            
            if previewImages.count >= 2 {
                
                HStack(spacing: 8) {
                    
                    ForEach(previewImages.prefix(2), id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 155)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(10)
                    }
                }
                
            } else if let first = previewImages.first {
                
                Image(uiImage: first)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 155)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(10)
            }
        }
    }
}
