import SwiftUI

// MARK: - 播放页（1:1 还原 Figma 9880:14735 "Now Playing - Vinyl"）
// 设计尺寸：390×844，背景色 #F2F2F2
struct NowPlayingView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var player = MusicPlayer.shared
    @State private var showLyrics = false
    @State private var isDragging = false
    @State private var dragTime: TimeInterval = 0

    var body: some View {
        VStack(spacing: 0) {

            // ── Top Bar（Figma：高60，<  NOW PLAYING  ...）──
            AppHeader(
                title: "NOW PLAYING".localized,
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("<")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                ),
                rightItem: AnyView(
                    Menu {
                        Button("Share", action: {})
                        Button("Track Info", action: {})
                    } label: {
                        Text("...")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                )
            )

            // ── Turntable Base（Figma：y=92, 342×400）──
            VinylTurntableView()
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .frame(height: 360)

            // ── Track Info（Figma：y=557）──
            VStack(alignment: .leading, spacing: 4) {
                Text(player.currentTrack?.title ?? "Skeuomorphic Dreams")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(player.currentTrack?.artist ?? "The Vinyl Orchestra")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40) // 调整间距

            // ── Progress Bar（Figma：y=661）──
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 16) {
                    Text(formatDuration(isDragging ? dragTime : player.playbackTime))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 40, alignment: .leading)
                        .monospacedDigit()

                    GeometryReader { geo in
                        let totalW = geo.size.width
                        let pct = player.duration > 0
                            ? min(1, max(0, (isDragging ? dragTime : player.playbackTime) / player.duration))
                            : 0

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "#D8D8D8"))
                                .frame(height: 8)
                                .shadow(color: AppColors.shadowDark.opacity(0.5), radius: 2, x: 1, y: 1)
                                .shadow(color: AppColors.shadowLight, radius: 1, x: -1, y: -1)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.textPrimary)
                                .frame(width: totalW * CGFloat(pct), height: 8)
                        }
                        .frame(height: 8)
                        .contentShape(Rectangle().size(CGSize(width: totalW, height: 44)))
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { val in
                                    isDragging = true
                                    let pct = max(0, min(1, val.location.x / totalW))
                                    dragTime = pct * player.duration
                                }
                                .onEnded { val in
                                    let pct = max(0, min(1, val.location.x / totalW))
                                    player.seek(to: pct * player.duration)
                                    isDragging = false
                                }
                        )
                    }
                    .frame(height: 15)

                    Text(formatDuration(player.duration))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 40, alignment: .trailing)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 48) // Figma 间距约 104 (从 Info 到 Progress)

            Spacer()

            // ── Playback Controls（Figma：y=724）──
            HStack(alignment: .center, spacing: 0) {
                // LRC 歌词按钮
                Button(action: { showLyrics = true }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 40, height: 40)
                            .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                            .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                Spacer()

                // 上一曲
                Button(action: { player.skipPrevious() }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 56, height: 56)
                            .shadow(color: AppColors.shadowLight, radius: 5, x: -3, y: -3)
                            .shadow(color: AppColors.shadowDark, radius: 5, x: 3, y: 3)
                        Image(systemName: "backward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                Spacer()

                // 播放/暂停
                Button(action: { player.togglePlayPause() }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 72, height: 72)
                            .shadow(color: AppColors.shadowLight, radius: 7, x: -4, y: -4)
                            .shadow(color: AppColors.shadowDark, radius: 7, x: 4, y: 4)
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                Spacer()

                // 下一曲
                Button(action: { player.skipNext() }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 56, height: 56)
                            .shadow(color: AppColors.shadowLight, radius: 5, x: -3, y: -3)
                            .shadow(color: AppColors.shadowDark, radius: 5, x: 3, y: 3)
                        Image(systemName: "forward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                Spacer()

                // 播放模式切换 (替换 Q)
                Button(action: { player.togglePlaybackMode() }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 40, height: 40)
                            .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                            .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                        Image(systemName: player.playbackMode.iconName)
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 64)
        }
        .background(AppColors.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showLyrics) {
            LyricsView()
        }
    }
}
