import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var player = MusicPlayer.shared
    @State private var navigateToNowPlaying = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Top Bar - Standardized (Internal padding is sufficient)
            AppHeader(
                title: album.title,
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            // Hidden NavigationLink for programmatic navigation
            NavigationLink(destination: NowPlayingView(), isActive: $navigateToNowPlaying) {
                EmptyView()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    // 2. Album Cover
                    VStack(spacing: 24) {
                        ZStack {
                            if let image = album.coverImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 240, height: 240)
                                    .cornerRadius(24)
                            } else {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(DesignTokens.surfaceMain)
                                    .frame(width: 240, height: 240)
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .font(.system(size: 80))
                                            .foregroundColor(DesignTokens.textSecondary.opacity(0.1))
                                    )
                            }
                        }
                        .skeuoRaised(cornerRadius: 24)
                        
                        VStack(spacing: 8) {
                            Text(album.title)
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(DesignTokens.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            
                            Text(album.artist)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DesignTokens.textSecondary)
                        }
                        .padding(.horizontal, 40)
                        
                        // Play Buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                if let first = album.tracks.first {
                                    player.playTrack(first, in: album.tracks)
                                    navigateToNowPlaying = true
                                }
                            }) {
                                Text("Play All")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(DesignTokens.textPrimary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .skeuoRaised(cornerRadius: 24)
                            }
                            
                            Button(action: {
                                let shuffled = album.tracks.shuffled()
                                if let first = shuffled.first {
                                    player.playTrack(first, in: shuffled)
                                    navigateToNowPlaying = true
                                }
                            }) {
                                Text("Shuffle")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(DesignTokens.textPrimary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .skeuoRaised(cornerRadius: 24)
                            }
                        }
                    }
                    .padding(.top, 24)
                    
                    // 3. Track List
                    VStack(spacing: 0) {
                        ForEach(album.tracks.indices, id: \.self) { index in
                            let track = album.tracks[index]
                            AlbumTrackRow(
                                track: track,
                                index: index,
                                isSelected: player.currentTrack?.id == track.id,
                                onPlay: {
                                    player.playTrack(track, in: album.tracks)
                                    navigateToNowPlaying = true
                                }
                            )
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
        .transaction { transaction in
            transaction.animation = nil // Disable page entrance jitter
        }
    }
}

struct AlbumTrackRow: View {
    let track: Track
    let index: Int
    let isSelected: Bool
    let onPlay: () -> Void
    
    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 16) {
                Text(String(format: "%02d", index + 1))
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
                
                Text(track.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isSelected ? DesignTokens.textActive : DesignTokens.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(track.duration)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(isSelected ? Color.black.opacity(0.05) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
