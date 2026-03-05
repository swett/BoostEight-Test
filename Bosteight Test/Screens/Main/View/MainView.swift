//
//  MainView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 03.03.2026.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.color87B3FB
                .ignoresSafeArea(.all)
            VStack {
                header
                main
                    .padding(.top, 92)
            }
        }
    }
}

#Preview {
    MainView(viewModel: MainViewModel(scanner: MediaScanner(), scanStore: ScanStore(scanResult: .empty)))
}


extension MainView {
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.storageTitle)
                    .foregroundStyle(Color.theme.colorFEFEFE)
                    .font(.sfRegular16)
                (  Text(viewModel.storageUsedFormatted)
                    .fontWeight(.semibold)
                    
                +
                Text(" of ")
                +
                Text(viewModel.storageTotalFormatted))
            }
            .foregroundStyle(Color.theme.colorFEFEFE)
            .font(.sfRegular16)
            Spacer()
            CircularProgressBarView(progress: viewModel.storageProgress)
                .frame(width: 148, height: 148)
        }
        .padding(.horizontal, 16)
    }
}


extension MainView {
    private var main: some View {
        Rectangle()
            .foregroundStyle(Color.theme.colorFFFFFF)
            .cornerRadius(30, corners: [.topLeft, .topRight])
            .ignoresSafeArea(.all)
            .overlay {
                ScrollView {
                    VStack {
                        CategoryCard(
                            type: .videoCompressor,
                            countText: videoCountText,
                            previewImages: viewModel.videoPreviewImages,
                            state: viewModel.videoCategoryState
                        ) {
                            viewModel.openVideoCompressor()
                        }
                        CategoryCard(
                            type: .media(nil),
                            countText: mediaCountText,
                            previewImages: viewModel.mediaPreviewImages,
                            state: viewModel.mediaCategoryState
                        ) {
                            viewModel.openMedia()
                        }
                        Spacer(minLength: 90)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
            }
    }
}


extension MainView {
    // variables for ui
    private var videoCountText: String {
        switch viewModel.videoCategoryState {
        case .locked:
            return "Access required"
        case .loading:
            return "Scanning..."
        case .ready:
            return "\(viewModel.videoCount) videos • \(formatBytes(viewModel.videoSize))"
        }
    }

    private var mediaCountText: String {
        switch viewModel.mediaCategoryState {
        case .locked:
            return "Access required"
        case .loading:
            return "Scanning..."
        case .ready:
            return "\(viewModel.mediaCount) items • \(formatBytes(viewModel.mediaSize))"
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .decimal
        return formatter.string(fromByteCount: bytes)
    }
}
