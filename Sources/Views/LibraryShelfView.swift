import SwiftUI
import UIKit

struct LibraryShelfView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var expandedAlbumKey: String?
    @State private var navigateToNowPlaying = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerSection
            hiddenNavSection
            albumListSection
        }
        .background(DesignTokens.surfaceSecondary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private var headerSection: some View {
        AppHeader(
            title: "MY COLLECTION",
            leftItem: AnyView(
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                }
            ),
            rightItem: AnyView(
                NavigationLink(destination: LibraryGridView()) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                }
            )
        )
    }
    
    private var hiddenNavSection: some View {
        NavigationLink(destination: NowPlayingView(), isActive: $navigateToNowPlaying) {
            EmptyView()
        }
    }
    
    private var albumListSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(libraryService.albums, id: \.id) { album in
                    AlbumShelfSpine(
                        album: album,
                        isExpanded: expandedAlbumKey == album.id,
                        onTap: { toggleExpansion(for: album) },
                        onPlayTrack: { playTrack($0, in: album) }
                    )
                    .id(album.id)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: expandedAlbumKey)
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
    }
    
    private func toggleExpansion(for album: Album) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if expandedAlbumKey == album.id {
                expandedAlbumKey = nil
            } else {
                expandedAlbumKey = album.id
            }
        }
    }
    
    private func playTrack(_ track: Track, in album: Album) {
        MusicPlayer.shared.playTrack(track, in: album.tracks)
        navigateToNowPlaying = true
    }
}

struct AlbumShelfSpine: View {
    let album: Album
    let isExpanded: Bool
    let onTap: () -> Void
    let onPlayTrack: (Track) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            SpineHeaderView(album: album, isExpanded: isExpanded, onTap: onTap)
                .zIndex(10)
            
            if isExpanded {
                TrackListView(album: album, onPlayTrack: onPlayTrack)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                    .zIndex(0)
            }
        }
    }
}

struct SpineHeaderView: View {
    let album: Album
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            backgroundImage
            metallicOverlay
            textContent
        }
        .frame(height: 80)
        .contentShape(Rectangle()) // 🚀 Ensure hit target is exactly 80pt
        .onTapGesture(perform: onTap) // 🚀 Use gesture to prevent event bubbling/conflict
        .cornerRadius(12)
        .skeuoRaised(cornerRadius: 12)
    }
    
    private var backgroundImage: some View {
        Group {
            if let cover = album.coverImage {
                Image(uiImage: cover)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 80)
                    .blur(radius: 20)
                    .overlay(Color.black.opacity(0.4))
                    .clipped()
            } else {
                Color.black.opacity(0.8)
            }
        }
    }
    
    private var metallicOverlay: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.15), Color.clear, Color.black.opacity(0.2)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var textContent: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title.uppercased())
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(album.artist.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding(.horizontal, 24)
    }
}

struct TrackListView: View {
    let album: Album
    let onPlayTrack: (Track) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(album.tracks) { track in
                TrackRowView(track: track, onPlay: { onPlayTrack(track) })
                Divider().padding(.horizontal, 24)
            }
            
            NavigationLink(destination: AlbumDetailView(album: album)) {
                Text("VIEW FULL ALBUM")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(DesignTokens.textActive)
                    .padding(.vertical, 18)
            }
        }
        .background(DesignTokens.surfaceLight.opacity(0.8))
        .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
    }
}


struct TrackRowView: View {
    let track: Track
    let onPlay: () -> Void
    @StateObject private var player = MusicPlayer.shared
    
    var body: some View {
        let isSelected = player.currentTrack?.id == track.id
        
        Button(action: onPlay) {
            HStack {
                Text(track.title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? DesignTokens.textActive : DesignTokens.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(formatDuration(track.duration))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isSelected ? DesignTokens.textActive.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
