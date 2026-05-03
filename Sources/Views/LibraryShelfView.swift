import SwiftUI

struct LibraryShelfView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var player = MusicPlayer.shared
    @State private var expandedAlbumID: String? = nil
    @Environment(\.presentationMode) var presentationMode
    
    // 🚀 注入控制视图切换的状态
    @Binding var isGridView: Bool
    @State private var showSearch = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header: 恢复所有功能
            AppHeader(
                title: "MY COLLECTION",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { isGridView.toggle() }) { // 🚀 恢复方格切换
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            // 2. Shelf Content
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(libraryService.albums) { album in
                        NewAlbumShelfItem(
                            album: album,
                            isExpanded: expandedAlbumID == album.id,
                            onToggle: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
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
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
    }
}

struct NewAlbumShelfItem: View {
    let album: Album
    let isExpanded: Bool
    let onToggle: () -> Void
    @StateObject private var player = MusicPlayer.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // 🚀 头部：使用独立容器，确保点击绝不透传
            ZStack {
                // Background
                if let cover = album.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 100)
                        .blur(radius: 20)
                        .overlay(Color.black.opacity(0.45))
                        .clipped()
                } else {
                    DesignTokens.surfaceLight.frame(height: 100)
                }
                
                // Content
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(album.title.uppercased())
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(album.artist.uppercased())
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
            }
            .frame(height: 100)
            .cornerRadius(12)
            .skeuoRaised(cornerRadius: 12)
            .contentShape(Rectangle())
            .onTapGesture(perform: onToggle) // 🚀 使用 Gesture 替代 Button，彻底隔离
            
            // 🚀 列表：只有在展开时才渲染，避免占位冲突
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(album.tracks) { track in
                        NewTrackRow(track: track) {
                            player.playTrack(track, in: album.tracks)
                            player.showNowPlaying = true // 🚀 恢复点击跳转播放页
                        }
                        if track.id != album.tracks.last?.id {
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 10)
                .background(DesignTokens.surfaceLight.opacity(0.3))
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
        }
    }
}

struct NewTrackRow: View {
    let track: Track
    let action: () -> Void
    @ObservedObject var player = MusicPlayer.shared
    
    var body: some View {
        let isSelected = player.currentTrack?.id == track.id
        
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title)
                        .font(.system(size: 15, weight: isSelected ? .black : .bold))
                        .foregroundColor(isSelected ? DesignTokens.accent : DesignTokens.textPrimary)
                    Text(track.artist)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignTokens.textSecondary.opacity(0.8))
                }
                Spacer()
                Text(track.duration)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(isSelected ? DesignTokens.accent.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
