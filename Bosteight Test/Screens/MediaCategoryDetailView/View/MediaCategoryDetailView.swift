//
//  MediaCategoryDetailView.swift
//  Bosteight Test
//
//  Created by Mykyta Kurochka on 04.03.2026.
//

import SwiftUI

struct MediaCategoryDetailView: View {
    @StateObject var viewModel: MediaCategoryDetailViewModel
    var body: some View {
        ZStack(alignment: .top) {
            Color.theme.colorFFFFFF
                .ignoresSafeArea(.all)
            VStack {
                header
                content
            }
            VStack {
                Spacer()
                if viewModel.selectedCount > 0 {
                    deleteBar
                }
            }
        }
        .alert(
            "Cleaner wants to delete photos",
            isPresented: $viewModel.showDeleteAlert
        ) {
            Button("Delete", role: .destructive) {
                viewModel.confirmDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You can restore them later from your gallery if needed.")
        }
    }
}

#Preview {
    MediaCategoryDetailView(
            viewModel: MediaCategoryDetailViewModel(
                subcategory: .duplicatePhotos,
                scanStore: MockScanStore(),
                photoService: MockPhotoLibraryService()
            )
        )
}


extension MediaCategoryDetailView {
    private var header: some View {
        VStack {
            HStack {
                
                Button {
                    viewModel.popBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.theme.color2B2B2B)
                        .font(.sfRegular17)
                }
                
                Spacer()
                
                
                
                if viewModel.selectedCount > 0 {
                    Button {
                        
                    } label: {
                        HStack {
                            Image(systemName: "chekmark")
                            Text("Deselect all")
                        }
                        .font(.sfMedium14)
                        .foregroundStyle(Color.theme.color2B2B2B)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6.5)
                        .background {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(Color.theme.colorFFFFFF)
                                .shadow(color: Color.theme.color2B2B2B.opacity(0.22),radius: 4.9)
                        }
                    }
                }
            }
            HStack {
                VStack(alignment: .leading,spacing: 10) {
                    Text(viewModel.title)
                        .font(.sfSemiBold24)
                        .foregroundStyle(Color.theme.color2B2B2B)
                    HStack {
                        BadgesView(iconName: "video_icon_black", text: viewModel.countOfFiles)
                        BadgesView(iconName: "storage_icon", text: viewModel.sizeOfFiles)
                    }
                    
                }
                Spacer()
            }
            .padding(.top, 10)
            
        }
        .padding(.horizontal, 16)
    }
    
}



extension MediaCategoryDetailView {
    var deleteBar: some View {
        
        Button {
            viewModel.deleteTapped()
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(Color.theme.color495AE9)
                .frame(height: 60)
                .overlay {
                    Text("Delete \(viewModel.selectedCount)( \(formatBytes(viewModel.selectedSize)))")
                        .font(.sfMedium16)
                        .foregroundStyle(Color.theme.colorFEFEFE
                        )
                }
            
            
        }
        .padding(.horizontal, 16)
    }
}


extension MediaCategoryDetailView {
    
    private var gridView: some View {
        
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        
        return ScrollView {
            
            LazyVGrid(columns: columns, spacing: 12) {
                
                ForEach(viewModel.gridAssets) { asset in
                    
                    AssetCellGrid(
                        asset: asset,
                        onTap: {
                            viewModel.toggleSelection(id: asset.id)
                        }
                    )
                }
            }
            .padding()
        }
    }
}


extension MediaCategoryDetailView {
    
    private var groupedView: some View {

        ScrollView {

            LazyVStack(spacing: 24) {

                ForEach(viewModel.groups) { group in

                    VStack(alignment: .leading, spacing: 12) {

                        groupHeader(group)

                        ScrollView(.horizontal, showsIndicators: false) {

                            LazyHStack(spacing: 12) {

                                ForEach(group.assets) { asset in

                                    AssetCellGrid(
                                        asset: asset,
                                        onTap: {
                                            viewModel.toggleSelection(id: asset.id)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.top)
        }
    }
    
    private func groupHeader(_ group: AssetGroup) -> some View {

        HStack {

            Text("\(group.assets.count) items")
                .font(.sfSemiBold16)
                .foregroundStyle(Color.theme.color2B2B2B)

            Spacer()

            Button {

                viewModel.toggleGroupSelection(group)

            } label: {

                Text(viewModel.isGroupSelected(group) ? "Deselect All" : "Select All")
                    .font(.sfMedium16)
                    .foregroundStyle(Color.theme.color858585)
            }
        }
        .padding(.horizontal)
    }
}

extension MediaCategoryDetailView {
    
    @ViewBuilder
    var content: some View {
        switch viewModel.screenType {
        case .grouped:
            groupedView
        case .grid:
            gridView
        }
    }
}
