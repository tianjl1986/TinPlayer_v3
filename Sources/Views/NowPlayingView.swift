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
                            .foregroundColor(themeManager.textPrimary)
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
                HStack(spacing: 16) { // 🚀 Figma 9880:14744
                    Text(formatDuration(player.currentTime))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(themeManager.textSecondary)
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(themeManager.currentTheme == .light ? Color(hex: "#E5E5E5") : Color(hex: "#222222"))
                            .frame(height: 8)
                            .skeuoSunken(radius: 8, offset: 4) // 🚀 Figma 9880:14746
                        
                        Capsule()
                            .fill(themeManager.currentTheme == .light ? Color(hex: "#404040") : Color.orange)
                            .frame(width: max(0, (UIScreen.main.bounds.width - 160) * (player.duration > 0 ? player.currentTime / player.duration : 0)), height: 8)
                    }
                    
                    Text(formatDuration(player.duration))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(themeManager.textSecondary)
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 48)

            Spacer()

            // 🚀 拟物化控制台 (Raised Buttons)
            HStack(spacing: 0) {
                Button(action: { showLyrics = true }) {
                    Text("LRC")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(themeManager.textSecondary)
                        .frame(width: 40, height: 40) // 🚀 Figma 9880:14749
                        .skeuoRaised(cornerRadius: 20)
                }
                Spacer()
                Button(action: { player.skipPrevious() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.textPrimary)
                        .frame(width: 56, height: 56) // 🚀 Figma 9880:14751
                        .skeuoRaised(cornerRadius: 28)
                }
                Spacer()
                Button(action: { player.togglePlayPause() }) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28))
                        .foregroundColor(themeManager.textPrimary)
                        .frame(width: 72, height: 72) // 🚀 Figma 9880:14753
                        .skeuoRaised(cornerRadius: 36)
                }
                Spacer()
                Button(action: { player.skipNext() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.textPrimary)
                        .frame(width: 56, height: 56) // 🚀 Figma 9880:14755
                        .skeuoRaised(cornerRadius: 28)
                }
                Spacer()
                Button(action: { player.togglePlaybackMode() }) {
                    Text("Q")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(themeManager.textSecondary)
                        .frame(width: 40, height: 40) // 🚀 Figma 9880:14757
                        .skeuoRaised(cornerRadius: 20)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
        }
        .background(themeManager.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showLyrics) {
            LyricsView()
        }
    }
}
