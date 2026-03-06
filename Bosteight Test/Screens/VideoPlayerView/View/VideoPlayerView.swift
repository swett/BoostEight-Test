//
//  VideoPlayerView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 06.03.2026.
//

import SwiftUI
import Photos
import AVKit
struct VideoPlayerView: View {
    let asset: PHAsset
    let height: CGFloat

    @StateObject private var loader = VideoPlayerLoader()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black)

            switch loader.state {
            case .loading:
                thumbnail
                    .overlay(ProgressView().tint(.white))

            case .ready(let player):
                VideoPlayer(player: player)
                    .disabled(false)

            case .failed:
                thumbnail
                    .overlay(
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.white.opacity(0.6))
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .task { await loader.load(asset: asset) }
        .onDisappear { loader.pause() }
    }

    // Thumbnail shown while AVPlayerItem loads
    private var thumbnail: some View {
        Group {
            if let image = loader.thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                Image(systemName: "video.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
            }
        }
    }
}
