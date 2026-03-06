//
//  CircularProgressBarView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 03.03.2026.
//

import SwiftUI

struct CircularProgressBarView: View {

    let progress: Double
    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {

            Circle()
                .stroke(
                    Color.theme.colorF3F4FF.opacity(0.5),
                    style: StrokeStyle(lineWidth: 16)
                )
                .shadow(color: Color.theme.color5693F9, radius: 13.5)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color.theme.color5369ED,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.sfSemiBold24)
                    .foregroundStyle(Color.theme.colorFEFEFE)
                    .contentTransition(.numericText())

                Text("used")
                    .font(.sfRegular13)
                    .foregroundStyle(Color.theme.colorFEFEFE)
            }
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeInOut(duration: 0.25)) {
                animatedProgress = newValue
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
