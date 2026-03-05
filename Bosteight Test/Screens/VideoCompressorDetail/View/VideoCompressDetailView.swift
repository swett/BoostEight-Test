//
//  VideoCompressDetail.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 05.03.2026.
//

import SwiftUI

struct VideoCompressDetailView: View {
    @StateObject var viewModel: VideoCompressorDetailViewModel
    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if viewModel.isCompressing {
                    Color.theme.color87B3FB
                } else {
                    Color.theme.colorFFFFFF
                }
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: viewModel.isCompressing)
            
            Group {
                if viewModel.isCompressing {
                    compressingStateView
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else if viewModel.isFinished {
                    finishedStateView
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    idleStateView
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: viewModel.isCompressing)
            .animation(.easeInOut(duration: 0.35), value: viewModel.isFinished)
        }
    }
}

#Preview {
    _VideoCompressorDetailPreview()
}


extension VideoCompressDetailView {
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Button { viewModel.popBack() } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color.theme.color2B2B2B)
                }
                Spacer()
            }
            Text("Video Compressor")
                .foregroundStyle(Color.theme.color2B2B2B)
                .font(.sfSemiBold24)
                .padding(.top, 16)
        }
        .padding(.bottom, 7)
        
    }
}

extension VideoCompressDetailView {
    private var videoThumbnail: some View {
        Group {
            if let asset = viewModel.asset {
                VideoThumbnailView(asset: asset, height: 288)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        Image(systemName: "video.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    )
            }
        }
        
    }
}

extension VideoCompressDetailView {
    private var sizeComparison: some View {
        HStack(spacing: 0) {
            sizeBlock(
                label: "Now",
                value: viewModel.formatBytes(viewModel.originalSize),
                color: .theme.color2B2B2B
            )
            
            HStack(spacing: -5) {
                Image(systemName: "chevron.forward")
                    .foregroundStyle(Color.theme.color495AE9.opacity(0.5))
                Image(systemName: "chevron.forward")
                    .foregroundStyle(Color.theme.color495AE9)
            }
            
            sizeBlock(
                label: "Will be",
                value: viewModel.formatBytes(viewModel.actualCompressedSize),
                color: .theme.color495AE9
            )
        }
        .padding(16)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        
    }
    
    private func sizeBlock(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.sfMedium16)
                .foregroundStyle(Color.theme.color858585)
            Text(value)
                .font(.sfSemiBold24)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}

extension VideoCompressDetailView {
    private var qualityPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(spacing: 12) {
                ForEach(VideoCompressionQuality.allCases, id: \.title) { quality in
                    qualityButton(quality)
                }
            }
        }
        
    }
    
    private func qualityButton(_ quality: VideoCompressionQuality) -> some View {
        let isSelected = viewModel.selectedQuality == quality
        return Button {
            viewModel.selectQuality(quality)
        } label: {
            HStack(spacing: 6) {
                Text(quality.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                ZStack {
                    // Stroke ring — visible only when unselected
                    Circle()
                        .stroke(Color.theme.color495AE9, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .opacity(isSelected ? 0 : 1)

                    // Filled checkmark — visible only when selected
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.theme.color495AE9)
                        .opacity(isSelected ? 1 : 0)
                }
                .frame(width: 24, height: 24)
                .animation(.easeInOut(duration: 0.15), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Color.theme.colorFFFFFF)
            .foregroundStyle(Color.theme.color495AE9)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.theme.color2B2B2B.opacity(0.15), radius: 3.8)
        }
        .disabled(viewModel.isCompressing)
    }
}

extension VideoCompressDetailView {
    private var mainActionButton: some View {
        Button {
            viewModel.startCompression()
        } label: {
            HStack {
                Image(systemName: "arrow.down.forward.and.arrow.up.backward")
                    .foregroundStyle(Color.theme.colorFFFFFF)
                Text("Compress")
                    .font(.sfMedium16)
                    .foregroundStyle(Color.theme.colorFFFFFF)
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.theme.color495AE9)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

extension VideoCompressDetailView {
    private var compressingStateView: some View {
            VStack(spacing: 0) {
                // Back header
                HStack {
                    Button { viewModel.cancelCompression() } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(Color.theme.colorFFFFFF)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 7)

                Spacer()

                // Central loader content
                VStack(spacing: 32) {
                    // Animated ring loader
                   ProgressView()
                        

                    VStack(spacing: 8) {
                        Text("\(Int(viewModel.compressionProgress * 100))%")
                            .font(.sfSemiBold24)
                            .foregroundStyle(Color.theme.colorFEFEFE)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: Int(viewModel.compressionProgress * 100))
                        Text("Compessing Video ...")
                            .font(.sfSemiBold24)
                            .foregroundStyle(Color.theme.colorFEFEFE)

                        
                    }
                }

                Spacer()

                // Bottom annotation + cancel
                VStack(spacing: 16) {
                    Text("Please don’t close the app in order\nnot to lose all progress")
                        .font(.sfRegular16)
                        .foregroundStyle(Color.theme.colorFFFFFF)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    Button {
                        viewModel.cancelCompression()
                    } label: {
                        Text("Cancel")
                            .font(.sfMedium16)
                            .foregroundStyle(Color.theme.colorFFFFFF)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.theme.colorFFFFFF.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 40)
            }
        }
}

extension VideoCompressDetailView {
    private var finishedStateView: some View {
           VStack(spacing: 19) {
               header
               finishedVideoThumbnail
               finishedSizeComparison
               Spacer()
               finishedActions
           }
           .padding(.horizontal, 16)
       }

       private var finishedVideoThumbnail: some View {
           ZStack(alignment: .topTrailing) {
               if let asset = viewModel.asset {
                   VideoThumbnailView(asset: asset, height: 458)
                  
               } else {
                   RoundedRectangle(cornerRadius: 16)
                       .fill(Color.gray.opacity(0.15))
                       .aspectRatio(16/9, contentMode: .fit)
                       .overlay(
                           Image(systemName: "video.fill")
                               .font(.largeTitle)
                               .foregroundStyle(.gray)
                       )
               }

               // Success badge
               HStack(spacing: 4) {
                   Image(systemName: "checkmark.circle.fill")
                       .foregroundStyle(.green)
                   Text("Done")
                       .font(.caption.weight(.semibold))
                       .foregroundStyle(Color.theme.color2B2B2B)
               }
               .padding(.horizontal, 10)
               .padding(.vertical, 6)
               .background(.white)
               .clipShape(Capsule())
               .shadow(color: .black.opacity(0.1), radius: 4)
               .padding(12)
           }
       }

       private var finishedSizeComparison: some View {
           VStack(spacing: 8) {
               HStack(spacing: 0) {
                   sizeBlock(
                       label: "Before",
                       value: viewModel.formatBytes(viewModel.originalSize),
                       color: Color.theme.color2B2B2B
                   )

                   HStack(spacing: -5) {
                       Image(systemName: "chevron.forward")
                           .foregroundStyle(Color.theme.color495AE9.opacity(0.5))
                       Image(systemName: "chevron.forward")
                           .foregroundStyle(Color.theme.color495AE9)
                   }

                   sizeBlock(
                       label: "After",
                       value: viewModel.formatBytes(viewModel.actualCompressedSize),
                       color: Color.theme.color495AE9
                   )
               }
               .padding(16)
               .clipShape(RoundedRectangle(cornerRadius: 16))

               // Saved badge
               let saved = viewModel.savedSize
               if saved > 0 {
                   HStack(spacing: 4) {
                       Image(systemName: "arrow.down.circle.fill")
                           .foregroundStyle(.green)
                       Text("Saved \(viewModel.formatBytes(saved))")
                           .font(.sfMedium16)
                           .foregroundStyle(.green)
                   }
                   .padding(.horizontal, 16)
                   .padding(.vertical, 8)
                   .background(Color.green.opacity(0.08))
                   .clipShape(Capsule())
               }
           }
       }

       private var finishedActions: some View {
           VStack(spacing: 12) {
               // Delete original
               Button {
                   Task { await viewModel.saveAndDeleteOriginal() }
               } label: {
                   HStack {
                       Text("Delete Original Video")
                           .font(.sfMedium16)
                           .foregroundStyle(Color.theme.color495AE9)
                   }
               }

               // Keep both
               Button {
                   Task { await viewModel.keepBoth() }
               } label: {
                   HStack {
                       Text("Keep Original Video")
                           .font(.sfMedium16)
                           .foregroundStyle(Color.theme.colorFFFFFF)
                   }
                   .frame(maxWidth: .infinity)
                   .padding(.vertical, 20)
                   .background(Color.theme.color495AE9)
                   .clipShape(RoundedRectangle(cornerRadius: 14))
               }
           }
           .padding(.bottom, 24)
       }
}


extension VideoCompressDetailView {
    private var idleStateView: some View {
            VStack(spacing: 19) {
                header
                videoThumbnail
                sizeComparison
                qualityPicker
                Spacer()
                mainActionButton
            }
            .padding(.horizontal, 16)
        }
}


private struct _VideoCompressorDetailPreview: View {
    var body: some View {
        VideoCompressDetailView(
            viewModel: VideoCompressorDetailViewModel(
                assetID: "MOCK-001",
                router: nil,
                scanStore: MockScanStore(),
                compressionService: MockVideoCompressionService(),
                estimator: VideoCompressionEstimator()
            )
        )
    }
}
