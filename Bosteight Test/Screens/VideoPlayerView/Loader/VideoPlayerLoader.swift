//
//  VideoPlayerLoader.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 06.03.2026.
//

import AVKit
import Photos
import Foundation

@MainActor
final class VideoPlayerLoader: ObservableObject {

    enum State {
        case loading
        case ready(AVPlayer)
        case failed
    }

    @Published var state: State = .loading
    @Published var thumbnail: UIImage?

    private var player: AVPlayer?

    func load(asset: PHAsset) async {
        // Load thumbnail immediately for fast perceived performance
        thumbnail = await fetchThumbnail(for: asset)

        // Request AVPlayerItem from Photos
        let item = await withCheckedContinuation { (continuation: CheckedContinuation<AVPlayerItem?, Never>) in
            var resumed = false
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic

            PHImageManager.default().requestPlayerItem(
                forVideo: asset,
                options: options
            ) { item, _ in
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: item)
            }
        }

        guard let item else {
            state = .failed
            return
        }

        let player = AVPlayer(playerItem: item)
        self.player = player

        // Loop playback
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        state = .ready(player)
    }

    func pause() {
        player?.pause()
    }

    private func fetchThumbnail(for asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { (continuation: CheckedContinuation<UIImage?, Never>) in
            var resumed = false
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.resizeMode = .fast
            options.isNetworkAccessAllowed = false

            let scale = UIScreen.main.scale
            let size = CGSize(
                width: UIScreen.main.bounds.width * scale,
                height: 288 * scale
            )

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool ?? false
                guard !isDegraded, !resumed else { return }
                resumed = true
                continuation.resume(returning: image)
            }
        }
    }
}
