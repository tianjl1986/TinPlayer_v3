import SwiftUI

struct LibraryShelfView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @State private var expandedAlbumID: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            AppHeader(title: "MY COLLECTION")
            
            // 2. Shelf Content
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(libraryService.albums, id: \.id) { album in
                        NewAlbumShelfItem(
                            album: album,
                            isExpanded: expandedAlbumID == album.id,
                            onToggle: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    expandedAlbumID = (expandedAlbumID == album.id) ? nil : album.id
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
    }
}

// 🚀 完全重构的单项组件，确保热区绝对隔离
struct NewAlbumShelfItem: View {
    let album: Album
    let isExpanded: Bool
    let onToggle: () -> Void
    @StateObject private var player = MusicPlayer.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // 头部：独立点击区域
            Button(action: onToggle) {
                ZStack {
                    // Background
                    if let cover = album.coverImage {
                        Image(uiImage: cover)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 100)
                            .blur(radius: 15)
                            .overlay(Color.black.opacity(0.4))
                            .clipped()
                    } else {
                        DesignTokens.surfaceLight.frame(height: 100)
                    }
                    
                    // Metallic Overlay
                    LinearGradient(
                        colors: [.white.opacity(0.1), .clear, .black.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Content
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(album.title.uppercased())
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text(album.artist.uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                                .lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                }
                .frame(height: 100)
                .cornerRadius(12)
                .skeuoRaised(cornerRadius: 12)
            }
            .buttonStyle(PlainButtonStyle())
            .zIndex(1)
            
            // 列表：独立区域，绝不重叠
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(album.tracks) { track in
                        NewTrackRow(track: track) {
                            player.playTrack(track, in: album.tracks)
                        }
                        if track.id != album.tracks.last?.id {
                            Divider().padding(.horizontal, 16).opacity(0.3)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(DesignTokens.surfaceLight.opacity(0.5))
                .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                .offset(y: -4) // 视觉贴合，但不影响点击
                .zIndex(0)
                .transition(.opacity.combined(with: .move(edge: .top)))
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
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 14, weight: isSelected ? .black : .bold))
                        .foregroundColor(isSelected ? DesignTokens.textActive : DesignTokens.textPrimary)
                    Text(track.artist)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DesignTokens.textSecondary.opacity(0.7))
                }
                Spacer()
                Text(formatDuration(track.duration))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(isSelected ? DesignTokens.textActive.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
