import SwiftUI

struct LibraryGridView: View {
    @EnvironmentObject var libraryService: MusicLibraryService
    @EnvironmentObject var musicPlayer: MusicPlayer
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var localizationManager = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    let filter: LibraryFilter
    @State private var isGridView = false // 🚀 默认书架视图，用户要求优先还原
    
    var filteredAlbums: [Album] {
        // Simple logic for now: libraryService.albums
        // In a real app, you'd sort/group differently
        libraryService.albums
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                AppHeader(
                    title: filter == .album ? "ALBUMS".localized : "ARTISTS".localized,
                    leftItem: AnyView(
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 44, height: 44)
                        }
                    ),
                    rightItem: AnyView(
                        Button(action: { isGridView.toggle() }) {
                            Image(systemName: isGridView ? "text.justify" : "square.grid.2x2")
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 44, height: 44)
                                .skeuoRaised(cornerRadius: 12)
                        }
                    )
                )
                
                ScrollView {
                    if isGridView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 24), GridItem(.flexible(), spacing: 24)], spacing: 24) {
                            ForEach(filteredAlbums) { album in
                                NavigationLink(destination: AlbumDetailView(album: album)) {
                                    AlbumGridItem(album: album)
                                }
                            }
                        }
                        .padding(24)
                    } else {
                        // 🚀 1:1 Bookshelf Layout
                        VStack(spacing: 12) {
                            ForEach(filteredAlbums) { album in
                                NavigationLink(destination: AlbumDetailView(album: album)) {
                                    AlbumBookshelfSpine(album: album)
                                }
                            }
                        }
                        .padding(24)
                    }
                    Spacer(minLength: 120)
                }
            }
            
            VStack {
                Spacer()
                MiniPlayerView()
            }
        }
        .navigationBarHidden(true)
    }
}

struct AlbumBookshelfSpine: View {
    let album: Album
    var body: some View {
        ZStack(alignment: .leading) {
            // 🚀 Spine Background with blurred cover
            if let image = album.coverImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 54)
                    .clipped()
                    .blur(radius: 20)
                    .overlay(Color.black.opacity(0.3)) // Darken for readability
            } else {
                Color(hex: "#1a1a1a")
                    .frame(height: 54)
            }
            
            HStack(spacing: 16) {
                // Vertical accent line (like CD spine)
                Rectangle()
                    .fill(Color.orange.opacity(0.8))
                    .frame(width: 4)
                    .frame(height: 54)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(album.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(album.artist)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.trailing, 16)
            }
        }
        .cornerRadius(8)
        .skeuoRaised(cornerRadius: 8)
    }
}

// Keep AlbumGridItem from previous file but updated for consistency
struct AlbumGridItem: View {
    let album: Album
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                if let image = album.coverImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 160)
                        .cornerRadius(4)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.textSecondary.opacity(0.1))
                        .frame(width: 160, height: 160)
                }
            }
            .skeuoRaised(cornerRadius: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(album.artist)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
        }
    }
}
