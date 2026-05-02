import SwiftUI

// MARK: - 歌词页（1:1 还原 Figma 9893:14777 "Lyrics - Typewriter"）
// 背景 #F2F2F2，顶部黑色滚轴，白色纸张，Courier New 16pt
struct LyricsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var lyricsService = LyricsService.shared
    @State private var isDragging = false
    @State private var dragTime: TimeInterval = 0

    var body: some View {
        VStack(spacing: 0) {

            // ── Top Bar（LYRICS，Inter Bold 14pt）──
            AppHeader(
                title: "LYRICS".localized,
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("<")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                ),
                rightItem: AnyView(
                    Button(action: {}) {
                        Text("...")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                )
            )

            // ── 打字机纸张区域（白色纸，顶部黑色压纸滚轴）──
            ZStack(alignment: .top) {
                // 白色纸张背景
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white)
                    .padding(.horizontal, 24)
                    .padding(.top, 48)  // 让纸张从滚轴下方开始
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)

                // 歌词内容（Courier New 16pt，居中）
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 32) {
                            // 顶部留白（纸张上边距 100）
                            Color.clear.frame(height: 80)

                            if displayLyrics.isEmpty {
                                Text("No Lyrics Found")
                                    .font(.custom("Courier New", size: 16))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.top, 40)
                            } else {
                                ForEach(displayLyrics.indices, id: \.self) { i in
                                    LyricLineView(
                                        text: displayLyrics[i].text,
                                        isCurrent: i == currentLineIndex
                                    )
                                    .id(i)
                                }
                            }

                            // 底部留白
                            Color.clear.frame(height: 120)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 56)
                    }
                    .padding(.top, 48)
                    .onChange(of: currentLineIndex) { newIdx in
                        withAnimation(.easeInOut(duration: 0.4)) {
                            proxy.scrollTo(newIdx, anchor: .center)
                        }
                    }
                }

                // 顶部压纸滚轴（Platen Roller）
                PlatenRollerView()
                    .zIndex(10)
            }
            .frame(maxHeight: .infinity)

            // ── 进度条（同NowPlaying，Inter Regular 12pt）──
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
                                dragTime = max(0, min(1, val.location.x / totalW)) * player.duration
                            }
                            .onEnded { val in
                                player.seek(to: max(0, min(1, val.location.x / totalW)) * player.duration)
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
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // ── 控制按钮（与NowPlaying相同布局）──
            HStack(alignment: .center, spacing: 0) {
                // LRC（已在此页，高亮）
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.background)
                    }
                }

                Spacer()

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
        .onAppear {
            if let title = player.currentTrack?.title,
               let artist = player.currentTrack?.artist {
                lyricsService.fetchLyrics(for: title, artist: artist)
            }
        }
    }

    private var displayLyrics: [LyricLine] {
        lyricsService.currentLyrics.isEmpty ? demoLyrics : lyricsService.currentLyrics
    }

    private var currentLineIndex: Int {
        displayLyrics.lastIndex(where: { $0.startTime <= player.playbackTime }) ?? 0
    }

    private let demoLyrics = [
        LyricLine(text: "The needle drops and the world slows down", startTime: 0),
        LyricLine(text: "Dust motes dancing in the fading light", startTime: 4),
        LyricLine(text: "Skeuomorphic dreams are comin'", startTime: 8),
        LyricLine(text: "Spinning shadows into the night", startTime: 12),
        LyricLine(text: "A melody of chrome and steel", startTime: 16),
        LyricLine(text: "The analog sound begins to heal", startTime: 20),
    ]
}

// MARK: - 单行歌词（Courier New 16pt，居中对齐）
struct LyricLineView: View {
    let text: String
    let isCurrent: Bool

    var body: some View {
        Text(text)
            .font(.custom("Courier New", size: 16))
            .fontWeight(isCurrent ? .bold : .regular)
            .foregroundColor(isCurrent ? AppColors.textPrimary : AppColors.textSecondary.opacity(0.5))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .animation(.easeInOut(duration: 0.3), value: isCurrent)
    }
}

// MARK: - 压纸滚轴（Platen Roller）
// Figma设计：顶部黑色粗滚轴 + 两侧银色圆柱端头
struct PlatenRollerView: View {
    var body: some View {
        ZStack {
            // 黑色主滚轴
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "#2A2A2A"), location: 0),
                            .init(color: Color(hex: "#111111"), location: 0.3),
                            .init(color: Color(hex: "#333333"), location: 0.7),
                            .init(color: Color(hex: "#1A1A1A"), location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 44)

            // 两侧银色端头
            HStack {
                RollerEndView()
                Spacer()
                RollerEndView()
            }
            .padding(.horizontal, 14)
        }
        .frame(maxWidth: .infinity)
        .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 4)
    }
}

struct RollerEndView: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: "#E8E8E8"),
                            Color(hex: "#AAAAAA"),
                            Color(hex: "#D0D0D0")
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 28, height: 56)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 2)
        }
    }
}
