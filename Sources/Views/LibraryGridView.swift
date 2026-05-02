import SwiftUI

struct LibraryGridView: View {
    @EnvironmentObject var libraryService: MusicLibraryService
    @EnvironmentObject var musicPlayer: MusicPlayer
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var localizationManager = LocalizationManager.shared
    @State private var isGridView = true
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    AppHeader(title: localizationManager.t("MY COLLECTION"), rightItem: AnyView(
                        Button(action: { isGridView.toggle() }) {
                            Image(systemName: isGridView ? "text.justify" : "square.grid.2x2")
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 44, height: 44)
                                .skeuoRaised(cornerRadius: 12)
                        }
                    ))
                    
                    ScrollView {
                        if isGridView {
                            LazyVGrid(columns: [GridItem(.flexible(), spacing: 24), GridItem(.flexible(), spacing: 24)], spacing: 24) {
                                ForEach(libraryService.albums) { album in
                                    NavigationLink(destination: AlbumDetailView(album: album)) {
                                        AlbumGridItem(album: album)
                                    }
                                }
                            }
                            .padding(20)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(libraryService.albums) { album in
                                    NavigationLink(destination: AlbumDetailView(album: album)) {
                                        AlbumBookshelfItem(album: album)
                                    }
                                }
                            }
                            .padding(20)
                        }
                        Spacer(minLength: 120)
                    }
                    .overlay(
                        VStack {
                            Spacer()
                            MiniPlayerView()
                        }
                    )
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
            .skeuoRaised(cornerRadius: 4)
            
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

struct AlbumBookshelfItem: View {
    let album: Album
    var body: some View {
        HStack(spacing: 16) {
            if let image = album.coverImage {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(4)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.textPrimary.opacity(0.1))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                Text(album.artist)
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.background)
        .skeuoRaised(cornerRadius: 12)
    }
}
