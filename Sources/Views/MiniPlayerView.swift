import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var showPlayer = false
    
    var body: some View {
        if let track = player.currentTrack {
            // Use Button instead of onTapGesture for better event handling
            Button(action: { showPlayer = true }) {
                HStack(spacing: 16) {
                    // Small Rotating Record
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 48, height: 48)
                            .skeuoRaised(cornerRadius: 24)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .frame(width: 40, height: 40)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                            .lineLimit(1)
                        Text(track.artist)
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { player.togglePlayPause() }) {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 16))
                                .foregroundColor(themeManager.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(themeManager.background)
                                .skeuoRaised(radius: 4, offset: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { player.skipNext() }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(themeManager.background)
                                .skeuoRaised(cornerRadius: 22)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(themeManager.background)
                .skeuoSunken(radius: 8, offset: 4)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .fullScreenCover(isPresented: $showPlayer) {
                NowPlayingView()
            }
        }
    }
}
