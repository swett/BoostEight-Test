//
//  CheckBoxView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import SwiftUI

struct CheckBoxView: View {
    var isSelected: Bool
    var body: some View {
        if isSelected {
            Image(systemName: "checkmark.square.fill")
                .foregroundStyle(Color.theme.color495AE9)
                .font(.system(size: 24))
                
        } else {
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.theme.color495AE9, lineWidth: 2)
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    CheckBoxView(isSelected: false)
}
