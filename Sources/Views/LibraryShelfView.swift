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
            // Spine Header - White background as requested
            Button(action: onTap) {
                HStack(spacing: 16) {
                    if let cover = album.coverImage {
                        Image(uiImage: cover)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .cornerRadius(6)
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(DesignTokens.shadowDark.opacity(0.2))
                            .frame(width: 48, height: 48)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(album.title.uppercased())
                            .font(.system(size: 15, weight: .black))
                            .foregroundColor(DesignTokens.textPrimary)
                        Text(album.artist.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(DesignTokens.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(DesignTokens.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.horizontal, 20)
                .frame(height: 80)
                .background(Color.white) // Changed to white as requested
                .cornerRadius(12)
                .skeuoRaised(cornerRadius: 12)
            }
            .buttonStyle(PlainButtonStyle())
            .zIndex(1)
            
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(album.tracks) { track in
                        Button(action: { onPlayTrack(track) }) {
                            HStack {
                                Text(track.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(DesignTokens.textPrimary)
                                Spacer()
                                Text(track.duration)
                                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                                    .foregroundColor(DesignTokens.textSecondary)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(Color.black.opacity(0.02))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.horizontal, 24)
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
                .padding(.top, -12) // Overlap with spine
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(0)
            }
        }
    }
}
