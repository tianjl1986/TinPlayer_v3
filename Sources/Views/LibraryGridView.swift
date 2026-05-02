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
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    AppHeader(
                        title: "MY COLLECTION".localized,
                        rightItem: AnyView(
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "line.3.horizontal") // 🚀 Figma 的 "=" 图标
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(width: 40, height: 40)
                            }
                        )
                    )
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(libraryService.albums) { album in
                                NavigationLink(destination: AlbumDetailView(album: album)) {
                                    AlbumGridItem(album: album)
                                }
                            }
                        }
                        .padding(24)
                        Spacer(minLength: 120) // 🚀 为 MiniPlayer 留出空间
                    }
                }
                
                MiniPlayerView()
                    .padding(.bottom, 10)
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
