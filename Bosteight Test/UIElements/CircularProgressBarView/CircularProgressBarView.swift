//
//  CircularProgressBarView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 03.03.2026.
//

import SwiftUI

struct CircularProgressBarView: View {
    private let progress: Double
    
    init(progress: Double) {
        self.progress = progress
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.theme.colorF3F4FF.opacity(0.5), style: StrokeStyle(lineWidth: 16))
                .shadow(color: Color.theme.color5693F9,radius: 13.5)
            
            Circle()
                .trim(from: 0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(Color.theme.color5369ED, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear, value: progress)
            VStack {
                Text("\(Int(progress * 100))%")
                    .font(.sfSemiBold24)
                    .foregroundStyle(Color.theme.colorFEFEFE)
                    .multilineTextAlignment(.center)
                Text("used")
                    .font(.sfRegular13)
                    .foregroundStyle(Color.theme.colorFEFEFE)
                
            }
                
        }
    }
}

#Preview {
    ZStack {
        Color.theme.color87B3FB
            .ignoresSafeArea(.all)
        
        CircularProgressBarView(progress: 0.5)
            .frame(width: 183, height: 183)
    }
}
