//
//  MediaHomeView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 03.03.2026.
//

import SwiftUI

struct MediaHomeView<ViewModel: MediaHomeViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.colorFFFFFF
                .ignoresSafeArea(.all)
            VStack {
                header
                cells
            }
        }
    }
}

#Preview {
    MediaHomeView(viewModel: MockMediaHomeViewModel())
}


extension MediaHomeView {
    private var header: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
//                    viewModel
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color.theme.color2B2B2B)
                }
            }
            Text("Media")
                .foregroundStyle(Color.theme.color2B2B2B)
                .font(.sfSemiBold24)
        }
    }
}


extension MediaHomeView {
    private var cells: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.items) { item in
                    MediaCategoryCell(model: item)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
