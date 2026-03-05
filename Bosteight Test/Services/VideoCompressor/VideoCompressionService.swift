//
//  VideoCompressionService.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import Photos
import AVKit

final class VideoCompressionService: VideoCompressionServiceProtocol {

    private let imageManager = PHImageManager.default()
    private var exportSession: AVAssetExportSession?

    func cancel() {
        exportSession?.cancelExport()
    }

    func compress(
        asset: PHAsset,
        quality: VideoCompressionQuality
    ) -> AsyncStream<VideoCompressionState> {

        AsyncStream { continuation in

            Task {

                continuation.yield(.preparing)

                guard let avAsset = await loadAVAsset(for: asset) else {
                    continuation.yield(.failed(VideoCompressionError.assetLoadFailed))
                    continuation.finish()
                    return
                }

                let originalSize = await assetSize(asset)

                let outputURL = FileManager.default
                    .temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("mp4")

                guard let export = AVAssetExportSession(
                    asset: avAsset,
                    presetName: quality.preset
                ) else {

                    continuation.yield(.failed(VideoCompressionError.exportCreationFailed))
                    continuation.finish()
                    return
                }

                exportSession = export

                export.outputURL = outputURL
                export.outputFileType = .mp4
                export.shouldOptimizeForNetworkUse = true

                export.exportAsynchronously { [weak self] in

                    guard let self else { return }

                    switch export.status {

                    case .completed:

                        let compressedSize = (try? FileManager.default
                            .attributesOfItem(atPath: outputURL.path)[.size] as? Int64) ?? 0

                        let result = VideoCompressionResult(
                            originalAsset: asset,
                            compressedURL: outputURL,
                            originalSize: originalSize,
                            compressedSize: compressedSize
                        )

                        continuation.yield(.finished(result: result))

                    case .failed:
                        continuation.yield(.failed(export.error ?? VideoCompressionError.unknown))

                    case .cancelled:
                        continuation.yield(.cancelled)

                    default:
                        break
                    }

                    continuation.finish()
                    self.exportSession = nil
                }

                // progress polling

                while export.status == .exporting {

                    continuation.yield(
                        .compressing(progress: Double(export.progress))
                    )

                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
            }
        }
    }
}

extension VideoCompressionService {

    func loadAVAsset(for asset: PHAsset) async -> AVAsset? {

            await withCheckedContinuation { continuation in

                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                options.deliveryMode = .automatic

                imageManager.requestAVAsset(
                    forVideo: asset,
                    options: options
                ) { avAsset, _, _ in

                    continuation.resume(returning: avAsset)
                }
            }
        }
    
    func assetSize(_ asset: PHAsset) async -> Int64 {

        let resources = PHAssetResource.assetResources(for: asset)

        guard let resource = resources.first else { return 0 }

        if let value = resource.value(forKey: "fileSize") as? Int64 {
            return value
        }

        return 0
    }
    
    func saveCompressedVideo(from url: URL) async throws {

        try await PHPhotoLibrary.shared().performChanges {

            PHAssetCreationRequest.creationRequestForAssetFromVideo(
                atFileURL: url
            )
        }
    }
    
    func deleteOriginal(asset: PHAsset) async throws {

        try await PHPhotoLibrary.shared().performChanges {

            PHAssetChangeRequest.deleteAssets(
                [asset] as NSFastEnumeration
            )
        }
    }
    func keepBoth(
        compressedURL: URL,
        original: PHAsset
    ) async throws {

        try await saveCompressedVideo(from: compressedURL)
    }
}
