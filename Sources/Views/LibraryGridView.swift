import SwiftUI

struct LibraryGridView: View {
    @EnvironmentObject var libraryService: MusicLibraryService
    @EnvironmentObject var musicPlayer: MusicPlayer
    @ObservedObject var themeManager = ThemeManager.shared
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 自定义 Header (包含书架切换)
                    AppHeader(title: localizationManager.t("MY COLLECTION")) {
                        Button(action: { isGridView.toggle() }) {
                            Image(systemName: isGridView ? "text.justify" : "square.grid.2x2")
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 44, height: 44)
                                .skeuoRaised(cornerRadius: 12)
                        }
                    }
                    
                    ScrollView {
                        if isGridView {
                            // 网格视图
                            LazyVGrid(columns: [GridItem(.fixed(163), spacing: 24), GridItem(.fixed(163), spacing: 24)], spacing: 24) {
                                ForEach(libraryService.albums) { album in
                                    NavigationLink(destination: AlbumDetailView(album: album)) {
                                        AlbumGridItem(album: album)
                                    }
                                }
                            }
                            .padding(.top, 24)
                        } else {
                            // 🚀 书架视图 (Bookshelf)
                            VStack(spacing: 16) {
                                ForEach(libraryService.albums) { album in
                                    NavigationLink(destination: AlbumDetailView(album: album)) {
                                        AlbumBookshelfItem(album: album)
                                    }
                                }
                            }
                            .padding(20)
                        }
                        Spacer(minLength: 120) // 🚀 为 MiniPlayer 留出空间
                    }
                    
                    MiniPlayerView()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct AlbumGridItem: View {
    let album: Album
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                if let image = album.coverImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 163, height: 163)
                        .cornerRadius(4)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.textPrimary.opacity(0.1))
                        .frame(width: 163, height: 163)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(album.artist)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
