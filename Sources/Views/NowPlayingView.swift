import SwiftUI

struct NowPlayingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var player = MusicPlayer.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showLyrics = false
    @State private var isDragging = false
    @State private var dragTime: TimeInterval = 0

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: "NOW PLAYING".localized,
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                )
            )

            // 🚀 黑胶盘面 (Figma 9880:14735)
            VinylTurntableView()
                .frame(width: 390, height: 380)
                .padding(.top, 20)

            // 🚀 曲目信息
            VStack(spacing: 8) {
                Text(player.currentTrack?.title ?? "No Track")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(player.currentTrack?.artist ?? "Unknown Artist")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, 40)

            // 🚀 拟物化进度条 (Sunken Track)
            VStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    // 凹陷轨道
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.background)
                        .skeuoSunken(cornerRadius: 4)
                        .frame(height: 8)
                    
                    // 进度填充 (可选，设计稿若有则加)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.textPrimary.opacity(0.3))
                        .frame(width: CGFloat((isDragging ? dragTime : player.currentTime) / (player.duration > 0 ? player.duration : 1)) * 342, height: 8)
                    
                    // 凸起滑块
                    Circle()
                        .fill(AppColors.background)
                        .frame(width: 24, height: 24)
                        .skeuoRaised(cornerRadius: 12)
                        .offset(x: CGFloat((isDragging ? dragTime : player.currentTime) / (player.duration > 0 ? player.duration : 1)) * 342 - 12)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    isDragging = true
                                    let percent = min(max(0, Double(value.location.x / 342)), 1)
                                    dragTime = percent * player.duration
                                }
                                .onEnded { _ in
                                    player.seek(to: dragTime)
                                    isDragging = false
                                }
                        )
                }
                .frame(width: 342)
                
                HStack {
                    Text(formatDuration(isDragging ? dragTime : player.currentTime))
                    Spacer()
                    Text(formatDuration(player.duration))
                }
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 24)
            }
            .padding(.top, 48)

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
