import SwiftUI

struct NowPlayingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var player = MusicPlayer.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showLyrics = false
    @State private var isDragging = false
    @State private var dragTime: TimeInterval = 0

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: localizationManager.t("NOW PLAYING"),
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                )
            )
            
            Spacer()
            
            // 1. 黑胶唱机 (320pt)
            VinylTurntableView()
                .padding(.bottom, 60)
            
            // 2. 歌曲信息 (间距对齐 Figma)
            VStack(spacing: 8) {
                Text(player.currentTrack?.title ?? localizationManager.t("UNKNOWN_TITLE"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(themeManager.textPrimary)
                Text(player.currentTrack?.artist ?? localizationManager.t("UNKNOWN_ARTIST"))
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.textSecondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 48)
            
            VStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(themeManager.background)
                        .frame(height: 6)
                        .skeuoSunken(radius: 4, offset: 2)
                    
                    Capsule()
                        .fill(Color(hex: "#404040"))
                        .frame(width: max(0, (UIScreen.main.bounds.width - 144) * (player.duration > 0 ? player.currentTime / player.duration : 0)), height: 6)
                }
                .padding(.horizontal, 48)
                .overlay(
                    HStack {
                        Text(formatDuration(player.currentTime))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(themeManager.textSecondary)
                            .frame(width: 48, alignment: .leading)
                        
                        Spacer()
                        
                        Text(formatDuration(player.duration))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(themeManager.textSecondary)
                            .frame(width: 48, alignment: .trailing)
                    }
                    .padding(.horizontal, 24)
                )
            }
            .padding(.bottom, 48)

            Spacer()

            // 🚀 拟物化控制台 (Raised Buttons)
            HStack(spacing: 0) {
                Button(action: { showLyrics = true }) {
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                        .skeuoRaised(cornerRadius: 22)
                }
                Spacer()
                Button(action: { player.skipPrevious() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 56, height: 56)
                        .skeuoRaised(cornerRadius: 28)
                }
                Spacer()
                Button(action: { player.togglePlayPause() }) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 80, height: 80) // 🚀 Figma 80x80
                        .skeuoRaised(cornerRadius: 40)
                }
                Spacer()
                Button(action: { player.skipNext() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 56, height: 56)
                        .skeuoRaised(cornerRadius: 28)
                }
                Spacer()
                Button(action: { player.togglePlaybackMode() }) {
                    Image(systemName: player.playbackMode.iconName)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                        .skeuoRaised(cornerRadius: 22)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
        }
        .background(AppColors.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showLyrics) {
            LyricsView()
        }
    }
}
