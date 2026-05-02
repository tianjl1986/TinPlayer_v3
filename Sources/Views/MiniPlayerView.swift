import SwiftUI

struct MiniPlayerView: View {
    @ObservedObject var player = MusicPlayer.shared
    @State private var showPlayer = false
    
    var body: some View {
        if let track = player.currentTrack {
            VStack(spacing: 0) {
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
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                        Text(track.artist)
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: { player.togglePlayPause() }) {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 44, height: 44)
                                .skeuoRaised(cornerRadius: 22)
                        }
                        
                        Button(action: { player.skipNext() }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 44, height: 44)
                                .skeuoRaised(cornerRadius: 22)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(AppColors.background)
                .skeuoSunken(cornerRadius: 24)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .onTapGesture { showPlayer = true }
            }
            .fullScreenCover(isPresented: $showPlayer) {
                NowPlayingView()
            }
        }
    }
}
