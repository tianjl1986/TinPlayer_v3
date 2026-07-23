import SwiftUI

struct LyricsView: View {
    @ObservedObject var player = MusicPlayer.shared
    @Binding var showLyrics: Bool
    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var theme = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            AppHeader(
                title: loc.t("LYRICS"),
                leftItem: AnyView(
                    Button(action: { showLyrics = false }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            // 2. Minimal raised lyrics panel
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(DesignTokens.surfaceMain)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(DesignTokens.skeuoShadowLight.opacity(theme.isDark ? 0.12 : 0.5), lineWidth: 1)
                    )
                    .skeuoRaised(cornerRadius: 28)

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .center, spacing: 32) {
                            Spacer(minLength: 140)
                            
                            if player.isSearchingLyrics {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .tint(DesignTokens.textPrimary)
                                    Text(loc.t("Searching lyrics..."))
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .foregroundColor(DesignTokens.textSecondary)
                                }
                                .padding(.top, 100)
                            } else if player.currentTrackLyrics.isEmpty || player.currentTrackLyrics.first?.text == "Lyrics not found online" {
                                VStack(spacing: 20) {
                                    Text(loc.t("Lyrics not found"))
                                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                                        .foregroundColor(DesignTokens.textSecondary.opacity(0.5))
                                    
                                    Button(action: {
                                        Task {
                                            await player.manualSearchLyrics()
                                        }
                                    }) {
                                        Text(loc.t("RETRY SEARCH"))
                                            .font(.system(size: 12, weight: .black))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(DesignTokens.surfaceSecondary)
                                            .cornerRadius(6)
                                            .foregroundColor(DesignTokens.textPrimary)
                                            .skeuoRaised(cornerRadius: 6)
                                    }
                                }
                                .padding(.top, 100)
                            } else {
                                ForEach(Array(player.currentTrackLyrics.enumerated()), id: \.offset) { index, line in
                                    Text(line.text)
                                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                                        .foregroundColor(index == player.currentLyricIndex ? DesignTokens.textPrimary : DesignTokens.textSecondary.opacity(0.4))
                                        .multilineTextAlignment(.center)
                                        .id(index)
                                }
                            }
                            
                            Spacer(minLength: 140)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 30)
                    }
                    .onChange(of: player.currentLyricIndex) { newIndex in
                        withAnimation(.spring()) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .mask(lyricsFadeMask)
            }
            .padding(.horizontal, 28)
            .padding(.top, 18)
            .padding(.bottom, 16)
            
            // 4. Progress Bar & Controls
            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    Text(formatDuration(player.currentTime))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(DesignTokens.textSecondary)
                        .frame(width: 50, alignment: .leading)
                    
                    progressBar
                    
                    Text(formatDuration(player.duration))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(DesignTokens.textSecondary)
                        .frame(width: 50, alignment: .trailing)
                }
                .padding(.horizontal, 32)
                
                BottomControlsView(showLyrics: $showLyrics)
                    .padding(.bottom, 30)
            }
            .padding(.top, 20)
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.startLocation.x < 50 && value.translation.width > 100 {
                        withAnimation { showLyrics = false }
                    }
                }
        )
    }

    /// Keeps the active lyric readable in the center while lines gently
    /// disappear at both edges of the raised panel.
    private var lyricsFadeMask: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.16),
                .init(color: .black, location: 0.84),
                .init(color: .clear, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.1))
                    .frame(height: 8)
                    .skeuoSunken(cornerRadius: 6)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.isDark ? Color.white.opacity(0.2) : Color.black.opacity(0.2))
                    .frame(width: geo.size.width * CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)), height: 8)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let percentage = min(max(0, value.location.x / geo.size.width), 1)
                        player.seek(to: player.duration * Double(percentage))
                    }
            )
        }
        .frame(height: 8)
    }
}
