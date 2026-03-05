//
//  ContentView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 02.03.2026.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var router: AppRouter
    @StateObject private var scanStore: ScanStore
    @StateObject private var mainViewModel: MainViewModel
    private let photoService: PhotoLibraryServiceProtocol = PhotoLibraryService()
    init() {
        let router = AppRouter()
        let scanStore = ScanStore(scanResult: .empty)
        let scanner = MediaScanner()
        
        _router = StateObject(wrappedValue: router)
        _scanStore = StateObject(wrappedValue: scanStore)
        _mainViewModel = StateObject(wrappedValue: MainViewModel(
            router: router,
            scanner: scanner,
            scanStore: scanStore
        ))
    }
    
    var body: some View {
        NavigationStack(path: $router.flowPath) {
            rootView
                .navigationDestination(for: FlowDestination.self) { destination in
                    destinationView(for: destination)
                        .navigationBarBackButtonHidden()
                }
        }
        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
       private var rootView: some View {
           switch router.currentFlow {
           case .onboarding:
               OnboardingView(
                   viewModel: OnboardingViewModel(router: router)
               )
           case .main:
               MainView(viewModel: mainViewModel)
           }
       }

       // MARK: - Destinations

       @ViewBuilder
       private func destinationView(for destination: FlowDestination) -> some View {
           switch destination {

           // MARK: Video Compressor
           case .videoCompressorList:
               VideoCompressorListView(
                   viewModel: VideoCompressorListViewModel(
                       router: router,
                       scanStore: scanStore
                   )
               )

           case .videoCompressorDetail(let assetID):
               VideoCompressDetailView(
                   viewModel: VideoCompressorDetailViewModel(
                       assetID: assetID,
                       router: router,
                       scanStore: scanStore,
                       compressionService: VideoCompressionService(),
                       estimator: VideoCompressionEstimator()
                   )
               )

           // MARK: Media
           case .mediaHome:
               MediaHomeView(
                   viewModel: MediaHomeViewModel(
                       router: router,
                       scanResult: scanStore.scanResult
                   )
               )

           case .mediaCategory(let subcategory):
               MediaCategoryDetailView(
                   viewModel: MediaCategoryDetailViewModel(
                       router: router,
                       subcategory: subcategory,
                       scanStore: scanStore,
                       photoService: photoService
                   )
               )
           }
       }
}

#Preview {
    ContentView()
}
