import SwiftUI

struct LibraryShelfView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var player = MusicPlayer.shared
    @State private var expandedAlbumID: String? = nil
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("is_grid_view") var isGridView: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header: 统一处理切换逻辑
            AppHeader(
                title: isGridView ? "COLLECTION" : "MY COLLECTION",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { 
                        withAnimation(.spring()) {
                            isGridView.toggle() 
                        }
                    }) {
                        // 切换图标：根据当前模式显示另一个模式的图标
                        Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            // 2. Content: 动态切换布局
            if isGridView {
                GridViewContent()
            } else {
                ShelfViewContent(expandedAlbumID: $expandedAlbumID)
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - 布局组件化

struct ShelfViewContent: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @Binding var expandedAlbumID: String?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 11) { 
                ForEach(libraryService.albums, id: \.id) { album in
                    AlbumShelfPill(
                        album: album,
                        isExpanded: expandedAlbumID == album.id,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if expandedAlbumID == album.id {
                                    expandedAlbumID = nil
                                } else {
                                    expandedAlbumID = album.id
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 100)
        }
    }
}

struct GridViewContent: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 网格标题（根据设计稿补齐）
                Text("\(libraryService.albums.count) ALBUMS")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(DesignTokens.textSecondary)
                    .padding(.horizontal, 24)
                
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(libraryService.albums) { album in
                        NavigationLink(destination: AlbumDetailView(album: album)) {
                            AlbumCard(album: album)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }
            .padding(.top, 24)
        }
    }
}

// MARK: - 原有组件逻辑保留并优化

struct AlbumShelfPill: View {
    let album: Album
    let isExpanded: Bool
    let onToggle: () -> Void
    @StateObject private var player = MusicPlayer.shared
    @State private var navigateToAlbum: Album? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if let cover = album.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 52) // Unified height reduction
                        .blur(radius: 12)
                        .overlay(Color.black.opacity(0.4))
                        .clipped()
                } else {
                    Color.black.opacity(0.8)
                }
                
                HStack {
                    Text("\(album.artist) - \(album.title)")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 24)
            }
            .frame(height: 52) // Unified height reduction
            .background(Color.black)
            .cornerRadius(6)
            .contentShape(Rectangle())
            .onTapGesture { onToggle() }
            // Removed skeuoRaised for shelf cards per user request to clean up shadows
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(album.tracks.indices), id: \.self) { index in
                        let track = album.tracks[index]
                        Button(action: {
                            if player.currentTrack?.id == track.id {
                                player.showNowPlaying = true
                            } else {
                                player.currentAlbum = album
                                player.playTrack(track, in: album.tracks)
                                player.showNowPlaying = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Text("\(index + 1).")
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(DesignTokens.textPrimary.opacity(0.4))
                                
                                Text(track.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(DesignTokens.textPrimary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if index < album.tracks.count - 1 {
                            Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 24)
                        }
                    }
                    
                    Button(action: { navigateToAlbum = album }) {
                        HStack {
                            Spacer()
                            Text("VIEW FULL ALBUM")
                                .font(.system(size: 10, weight: .black))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(DesignTokens.surfaceSecondary)
                                .cornerRadius(6)
                                .foregroundColor(DesignTokens.textPrimary)
                            Spacer()
                        }
                        .padding(.vertical, 16)
                    }
                }
                .background(DesignTokens.surfaceMain)
                .cornerRadius(6, corners: [.bottomLeft, .bottomRight])
                .padding(.top, 4)
            }
        }
        .fullScreenCover(item: $navigateToAlbum) { album in
            AlbumDetailView(album: album)
        }
    }
}
