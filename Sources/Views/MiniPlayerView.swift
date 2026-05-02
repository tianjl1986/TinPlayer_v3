import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var player = MusicPlayer.shared
    @State private var showPlayer = false
    
    var body: some View {
        if let track = player.currentTrack {
            VStack(spacing: 0) {
                Divider().background(AppColors.separator)
                HStack(spacing: 12) {
                    // Album Cover
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(AppColors.background)
                            .skeuoSunken(cornerRadius: 6)
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "music.note")
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                        Text(track.artist)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button(action: { player.togglePlayPause() }) {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(AppColors.textPrimary)
                            .font(.title3)
                            .frame(width: 40, height: 40)
                            .skeuoRaised(cornerRadius: 20)
                    }
                    
                    Button(action: { player.skipNext() }) {
                        Image(systemName: "forward.fill")
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                            .skeuoRaised(cornerRadius: 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(AppColors.background.opacity(0.95))
                .onTapGesture { showPlayer = true }
            }
            .fullScreenCover(isPresented: $showPlayer) {
                NowPlayingView()
            }
        }
    }
}
