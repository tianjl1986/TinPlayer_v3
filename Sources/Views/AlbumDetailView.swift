import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var player = MusicPlayer.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Top Bar - 9930:15071
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("<").font(.system(size: 20, weight: .bold))
                }
                Spacer()
                Text("ALBUM")
                    .font(.system(size: 16, weight: .black))
                Spacer()
                Text(" ") // Spacer
                    .frame(width: 20)
            }
            .foregroundColor(DesignTokens.textPrimary)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    // 2. Album Header - 9931:15076
                    VStack(spacing: 24) {
                        AsyncImage(url: URL(string: album.coverUrl)) { image in
                            image.resizable()
                        } placeholder: {
                            Rectangle().fill(Color.gray.opacity(0.1))
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 240, height: 240)
                        .cornerRadius(8)
                        .skeuoRaised(cornerRadius: 8)
                        
                        VStack(spacing: 8) {
                            Text(album.title)
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(DesignTokens.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(album.artist)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(DesignTokens.textSecondary)
                        }
                        
                        // Action Buttons - 9931:15078
                        HStack(spacing: 16) {
                            Button(action: { player.playTrack(album.tracks.first!, in: album.tracks) }) {
                                Text("Play All")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(DesignTokens.textPrimary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .skeuoRaised(cornerRadius: 24)
                            }
                            
                            Button(action: { /* Shuffle Action */ }) {
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
                    
                    // 3. Track List - 9931:15081
                    VStack(spacing: 16) {
                        ForEach(Array(album.tracks.enumerated()), id: \.offset) { index, track in
                            Button(action: { player.playTrack(track, in: album.tracks) }) {
                                HStack(spacing: 16) {
                                    Text(String(format: "%02d", index + 1))
                                        .font(.system(size: 12, weight: .black, design: .monospaced))
                                        .foregroundColor(DesignTokens.textSecondary)
                                    
                                    Text(track.title)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(player.currentTrack?.id == track.id ? DesignTokens.textActive : DesignTokens.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text(track.duration)
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(DesignTokens.textSecondary)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
        }
        .background(DesignTokens.surfaceLight.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
