//
//  OnboardingView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.colorFFFFFF
                .ignoresSafeArea(.all)
            VStack {
                info
                stepIndicator
                button
            }
        }
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel())
}


extension OnboardingView {
    private var info: some View {
        VStack {
            Image(viewModel.items[viewModel.step].image)
                .resizable()
                .scaledToFit()
                .frame(width: 284, height: DeviceType.IS_SMALL ? 382 : 522)
                
                .padding(.top, 10)
            
            VStack {
                Text(viewModel.items[viewModel.step].title)
                    .font(.sfSemiBold24)
                    .foregroundStyle(Color.theme.color2B2B2B)
                    .padding(.top, 22)
                Text(viewModel.items[viewModel.step].description)
                    .font(.sfMedium14)
                    .foregroundStyle(Color.theme.color858585)
                    .multilineTextAlignment(.center)
                    .padding(.top, 3)
            }
            .padding(.horizontal, 33)
            
        }
    }
}

extension OnboardingView {
    private var stepIndicator: some View {
        HStack {
            ForEach(0..<viewModel.items.count, id: \.self) {
                item in
                RoundedRectangle(cornerRadius: viewModel.step == item ? 10 : 100 )
                    .frame(width: viewModel.step == item ? 16 : 8, height: 8)
                    .foregroundStyle(viewModel.step == item ? Color.theme.color495AE9 : Color.theme.colorEAEAEA)
            }
        }
        .padding(.vertical, 24)
    }
}

extension OnboardingView {
    private var button: some View {
        Button {
            withAnimation(.easeIn) {
                viewModel.nextStep()
            }
            
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.theme.color495AE9)
                .frame(height: 60)
                .overlay {
                    Text("Continue")
                        .foregroundStyle(Color.theme.colorFEFEFE)
                        .font(.sfMedium16)
                }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
}
