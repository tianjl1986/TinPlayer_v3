import SwiftUI

struct LibraryGridView: View {
    @EnvironmentObject var libraryService: MusicLibraryService
    @EnvironmentObject var musicPlayer: MusicPlayer
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var localizationManager = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    let filter: LibraryFilter
    @State private var isGridView = false
    
    var filteredAlbums: [Album] {
        if filter == .artist {
            let grouped = Dictionary(grouping: libraryService.albums, by: { $0.artist })
            return grouped.values.compactMap { $0.first }.sorted(by: { $0.artist < $1.artist })
        }
        return libraryService.albums
    }
    
    var body: some View {
        ZStack {
            themeManager.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                AppHeader(
                    title: filter == .album ? localizationManager.t("ALBUMS") : localizationManager.t("ARTISTS"),
                    leftItem: AnyView(
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                                .frame(width: 44, height: 44)
                        }
                    ),
                    rightItem: AnyView(
                        Button(action: { isGridView.toggle() }) {
                            Image(systemName: isGridView ? "text.justify" : "square.grid.2x2")
                                .foregroundColor(themeManager.textPrimary)
                                .frame(width: 44, height: 44)
                                .skeuoRaised(cornerRadius: 12)
                        }
                    )
                )
                
                ScrollView(showsIndicators: false) {
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
                        // 🚀 1:1 Bookshelf Layout (Figma 9897:14825)
                        VStack(spacing: 8) { // 🚀 itemSpacing 8
                            ForEach(filteredAlbums) { album in
                                AlbumBookshelfSpine(album: album)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    }
                    Spacer(minLength: 140)
                }
            }
            
            VStack {
                Spacer()
                MiniPlayerView()
                    .padding(.bottom, 10)
            }
        }
        .navigationBarHidden(true)
    }
}

struct AlbumBookshelfSpine: View {
    let album: Album
    @State private var isExpanded = false
    @EnvironmentObject var musicPlayer: MusicPlayer
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        VStack(spacing: 4) { // 🚀 Figma 9897:14836 itemSpacing
            // 🚀 Spine Header Button (Fixed reliability)
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                ZStack(alignment: .leading) {
                    // Blurred background from cover
                    if let image = album.coverImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 54)
                            .clipped()
                            .blur(radius: 30) // 🚀 Figma 10024:16571
                            .overlay(Color.black.opacity(0.4))
                    } else {
                        Color(hex: "#1A1A1A")
                            .frame(height: 54)
                    }
                    
                    HStack(spacing: 16) {
                        // Color Indicator (Fixed per Figma)
                        Rectangle()
                            .fill(Color.orange.opacity(0.8))
                            .frame(width: 4, height: 54)
                        
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
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .padding(.trailing, 16)
                    }
                }
                .cornerRadius(8)
                .skeuoRaised(radius: 8, offset: 4) // 🚀 Figma matched shadow
            }
            .buttonStyle(PlainButtonStyle())
            
            // 🚀 Expanded Tracklist (Figma 9897:14840)
            if isExpanded {
                VStack(spacing: 0) {
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                            Text(localizationManager.t("ALBUM DETAILS"))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(16)
                        .background(Color.orange.opacity(0.05))
                    }
                    
                    Divider()
                        .opacity(0.1)
                    
                    ForEach(Array(album.tracks.enumerated()), id: \.element.id) { index, track in
                        Button(action: {
                            musicPlayer.playTrack(track, in: album.tracks)
                        }) {
                            HStack(spacing: 12) {
                                Text(String(format: "%02d", index + 1))
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(themeManager.textSecondary)
                                    .frame(width: 24)
                                
                                Text(track.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(musicPlayer.currentTrack?.id == track.id ? .orange : themeManager.textPrimary)
                                
                                Spacer()
                                
                                Text(track.duration)
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.textSecondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                        }
                        
                        if index < album.tracks.count - 1 {
                            Divider().padding(.leading, 52).opacity(0.05)
                        }
                    }
                }
                .background(themeManager.currentTheme == .light ? Color.white.opacity(0.8) : Color(hex: "#1A1A1A").opacity(0.8))
                .cornerRadius(8)
                .skeuoSunken(radius: 2, offset: 1)
                .padding(.top, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

struct AlbumGridItem: View {
    let album: Album
    @ObservedObject var themeManager = ThemeManager.shared
    
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
                        .fill(themeManager.textSecondary.opacity(0.1))
                        .frame(width: 160, height: 160)
                }
            }
            .skeuoRaised(radius: 4, offset: 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(themeManager.textPrimary)
                    .lineLimit(1)
                
                Text(album.artist)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(themeManager.textSecondary)
                    .lineLimit(1)
            }
        }
    }
}
