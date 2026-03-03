//
//  ColorExtension.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        
        let redValue = Double((rgb >> 16) & 0xFF) / 255.0
        let greenValue = Double((rgb >> 8) & 0xFF) / 255.0
        let blueValue = Double(rgb & 0xFF) / 255.0
        self.init(red: redValue, green: greenValue, blue: blueValue)
    }
}

extension Color {
    static let theme = ColorTheme()
}


struct ColorTheme {
    let colorFFFFFF = Color(hex: "#FFFFFF")
    let color000000 = Color(hex: "#000000")
    let color495AE9 = Color(hex: "#495AE9")
    let colorFEFEFE = Color(hex: "#FEFEFE")
    let color858585 = Color(hex: "#858585")
    let color2B2B2B = Color(hex: "#2B2B2B")
    let color87B3FB = Color(hex: "#87B3FB")
    let color1F1F1F = Color(hex: "#1F1F1F")
    let color636363 = Color(hex: "#636363")
    let colorEAEAEA = Color(hex: "#EAEAEA")
    
    let colorF3F4FF = Color(hex: "#F3F4FF")
    let color5369ED = Color(hex: "#5369ED")
    
    let colorEC2D30 = Color(hex: "#EC2D30")
    let colorFFCCD2 = Color(hex: "#FFCCD2")
    
    let colorF63BCD = Color(hex: "#F63BCD")
    let colorFF80BF = Color(hex: "#FF80BF")
    
    let color3B82F6 = Color(hex: "#3B82F6")
    let color8880FF = Color(hex: "#8880FF")
    
    
   
}


