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
                title: "NOW PLAYING",
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
                        Button("Add to Playlist", action: {})
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
                .padding(.top, 16)
                .frame(height: 360)

            // ── Track Info（Figma：y=557, 390×56）──
            // Song: Inter Regular 24pt；Artist: Inter Regular 16pt #808080
            VStack(alignment: .leading, spacing: 0) {
                Text(player.currentTrack?.title ?? "Skeuomorphic Dreams")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)

                Text(player.currentTrack?.artist ?? "The Vinyl Orchestra")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .frame(height: 72)

            // ── Progress Bar（Figma：y=661, 390×15）──
            // 左时间 Inter Regular 12pt，进度条 244宽 8高，右时间
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    // 左侧时间
                    Text(formatDuration(isDragging ? dragTime : player.playbackTime))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 40, alignment: .leading)
                        .monospacedDigit()

                    // 进度条轨道（Figma: Track Line 244×8）
                    GeometryReader { geo in
                        let totalW = geo.size.width
                        let pct = player.duration > 0
                            ? min(1, max(0, (isDragging ? dragTime : player.playbackTime) / player.duration))
                            : 0

                        ZStack(alignment: .leading) {
                            // 轨道背景（凹陷）
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "#D8D8D8"))
                                .frame(height: 8)
                                .shadow(color: AppColors.shadowDark.opacity(0.5), radius: 2, x: 1, y: 1)
                                .shadow(color: AppColors.shadowLight, radius: 1, x: -1, y: -1)

                            // 进度填充
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

                    // 右侧时间
                    Text(formatDuration(player.duration))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 40, alignment: .trailing)
                        .monospacedDigit()
                }
                .frame(height: 15)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer(minLength: 24)

            // ── Playback Controls（Figma：y=724, 390×72）──
            // 布局：LRC(40×40) ─── |<(56×56) ─── ||(72×72) ─── >|(56×56) ─── Q(40×40)
            HStack(alignment: .center, spacing: 0) {

                // LRC 歌词按钮（Inter Regular 12pt，40×40 圆形凸起）
                Button(action: { showLyrics = true }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 40, height: 40)
                            .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                            .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                        Text("LRC")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                Spacer()

                // |< 上一曲（Inter Regular 16pt，56×56）
                Button(action: { player.skipPrevious() }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 56, height: 56)
                            .shadow(color: AppColors.shadowLight, radius: 5, x: -3, y: -3)
                            .shadow(color: AppColors.shadowDark, radius: 5, x: 3, y: 3)
                        Text("|<")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                Spacer()

                // || 播放/暂停（Inter Regular 20pt，72×72）
                Button(action: { player.togglePlayPause() }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 72, height: 72)
                            .shadow(color: AppColors.shadowLight, radius: 7, x: -4, y: -4)
                            .shadow(color: AppColors.shadowDark, radius: 7, x: 4, y: 4)
                        Text(player.isPlaying ? "||" : "|>")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                Spacer()

                // >| 下一曲（Inter Regular 16pt，56×56）
                Button(action: { player.skipNext() }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 56, height: 56)
                            .shadow(color: AppColors.shadowLight, radius: 5, x: -3, y: -3)
                            .shadow(color: AppColors.shadowDark, radius: 5, x: 3, y: 3)
                        Text(">|")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }

                Spacer()

                // Q 队列（Inter Regular 12pt，40×40）
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 40, height: 40)
                            .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                            .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                        Text("Q")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .padding(.horizontal, 24)
            .frame(height: 72)
            .padding(.bottom, 48)
        }
        .background(AppColors.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showLyrics) {
            LyricsView()
        }
    }
}
