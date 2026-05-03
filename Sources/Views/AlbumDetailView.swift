import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @ObservedObject var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            AppHeader(
                title: "ALBUM",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // 2. Album Cover (1:1 280x280)
                    if let cover = album.coverImage {
                        Image(uiImage: cover)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 280, height: 280)
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 15)
                    } else {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(DesignTokens.surfaceMain)
                            .frame(width: 280, height: 280)
                            .skeuoSunken(cornerRadius: 24)
                    }
                    
                    // 3. Info Text
                    VStack(spacing: 8) {
                        Text(album.title)
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(DesignTokens.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("\(album.artist) • \(album.releaseYear)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(DesignTokens.textSecondary)
                    }
                    .padding(.horizontal, 40)
                    
                    // 4. Play Actions (1:1 Skeuo Buttons from Image 12)
                    HStack(spacing: 16) {
                        Button(action: { player.playAlbum(album) }) {
                            Text("Play All")
                                .font(.system(size: 15, weight: .black))
                                .foregroundColor(DesignTokens.textPrimary)
                                .frame(width: 140, height: 52)
                                .background(DesignTokens.surfaceMain)
                                .cornerRadius(26)
                                .skeuoRaised(cornerRadius: 26)
                        }
                        
                        Button(action: { /* Shuffle Action */ }) {
                            Text("Shuffle")
                                .font(.system(size: 15, weight: .black))
                                .foregroundColor(DesignTokens.textPrimary)
                                .frame(width: 140, height: 52)
                                .background(DesignTokens.surfaceMain)
                                .cornerRadius(26)
                                .skeuoRaised(cornerRadius: 26)
                        }
                    }
                    .padding(.top, 8)
                    
                    // 5. Track List (1:1 Fidelity)
                    VStack(spacing: 0) {
                        ForEach(Array(album.tracks.enumerated()), id: \.offset) { index, track in
                            Button(action: { player.playTrack(track, in: album.tracks) }) {
                                HStack(spacing: 20) {
                                    Text(String(format: "%02d", index + 1))
                                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                                        .foregroundColor(DesignTokens.textSecondary.opacity(0.6))
                                        .frame(width: 30, alignment: .leading)
                                    
                                    Text(track.title)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(DesignTokens.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text(formatDuration(track.duration))
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        .foregroundColor(DesignTokens.textSecondary.opacity(0.6))
                                }
                                .padding(.horizontal, 32)
                                .padding(.vertical, 20)
                                .background(Color.clear)
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .padding(.top, 16)
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .background(DesignTokens.surfaceSecondary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
