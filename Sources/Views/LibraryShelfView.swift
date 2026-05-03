import SwiftUI
import UIKit

struct LibraryShelfView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var expandedAlbumID: String?
    @State private var navigateToNowPlaying = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Top Bar - Fixed padding to avoid "too centered" buttons
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
                            .font(.system(size: 18))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            // Hidden NavigationLink for programmatic navigation
            NavigationLink(destination: NowPlayingView(), isActive: $navigateToNowPlaying) {
                EmptyView()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(libraryService.albums) { album in
                        AlbumShelfSpine(
                            album: album,
                            isExpanded: expandedAlbumID == album.id,
                            onTap: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    if expandedAlbumID == album.id {
                                        expandedAlbumID = nil
                                    } else {
                                        expandedAlbumID = album.id
                                    }
                                }
                            },
                            onPlayTrack: { track in
                                MusicPlayer.shared.playTrack(track, in: album.tracks)
                                navigateToNowPlaying = true
                            }
                        )
                    }
                }
                .padding(24)
            }
        }
        .background(DesignTokens.surfaceSecondary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct AlbumShelfSpine: View {
    let album: Album
    let isExpanded: Bool
    let onTap: () -> Void
    let onPlayTrack: (Track) -> Void
    @StateObject private var player = MusicPlayer.shared
    
    var body: some View {
        VStack(spacing: 0) {
            spineHeader
            
            if isExpanded {
                trackList
            }
        }
    }
    
    private var spineHeader: some View {
        Button(action: onTap) {
            ZStack {
                albumBackground
                
                headerContent
            }
            .frame(height: 80)
            .cornerRadius(12)
            .skeuoRaised(cornerRadius: 12)
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(1)
    }
    
    @ViewBuilder
    private var albumBackground: some View {
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
            
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.15), Color.clear, Color.black.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private var headerContent: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title.uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text(album.artist.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding(.horizontal, 24)
    }
    
    private var trackList: some View {
        VStack(spacing: 0) {
            ForEach(album.tracks) { track in
                TrackRowView(track: track, onPlay: { onPlayTrack(track) })
                
                Divider()
                    .padding(.horizontal, 24)
            }
            
            fullAlbumLink
        }
        .background(DesignTokens.surfaceLight.opacity(0.8))
        .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        .padding(.top, -12) // Overlap with spine
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(0)
    }
    
    private var fullAlbumLink: some View {
        NavigationLink(destination: AlbumDetailView(album: album)) {
            Text("VIEW FULL ALBUM")
                .font(.system(size: 11, weight: .black))
                .foregroundColor(DesignTokens.textActive)
                .padding(.vertical, 18)
        }
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
