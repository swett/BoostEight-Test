//
//  VideoCompressorListView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import SwiftUI
import PhotosUI
struct VideoCompressorListView: View {
    @StateObject var viewModel: VideoCompressorListViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    _VideoCompressorListPreview()
}


extension VideoCompressorListView {
    private var header: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    viewModel.popBack()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color.theme.color2B2B2B)
                }
            }
            Text("Video Compressor")
                .foregroundStyle(Color.theme.color2B2B2B)
                .font(.sfSemiBold24)
            
            BadgesView(iconName: "video_icon_black", text: viewModel.countText)
        }
    }
}


extension VideoCompressorListView {
    private var cells: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.assets, id: \.localIdentifier) { asset in
                    VideoCell(asset: asset, sizeText: viewModel.sizeText(for: asset))
                        .onTapGesture {
                            viewModel.didTapAsset(asset)
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}


// Separate preview view so we can use @StateObject with mock data
private struct _VideoCompressorListPreview: View {
    @StateObject private var mock = MockVideoCompressorListViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header preview
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.black)
                }
                Text("Video Compressor")
                    .font(.system(size: 24, weight: .semibold))
                 BadgesView(iconName: "video_icon_black", text: mock.countText)
//                Text(mock.countText)
//                    .font(.caption)
//                    .padding(.vertical, 4)
//                    .padding(.horizontal, 8)
//                    .background(Color.gray.opacity(0.15))
//                    .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.top)

            // Cells preview (ID + size label, no real PHAsset)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(mock.items) { item in
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.25))
                                .aspectRatio(1, contentMode: .fit)
                            Text(item.sizeText)
                                .font(.caption2)
                                .padding(6)
                                .background(Color.theme.color495AE9)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .padding(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 30)
        }
    }
}
