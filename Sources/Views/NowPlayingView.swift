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
                title: LocalizationManager.shared.t("NOW PLAYING"),
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("<")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                )
            )

            VinylTurntableView()
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .frame(height: 360)

            VStack(alignment: .leading, spacing: 4) {
                Text(player.currentTrack?.title ?? "No Track")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(player.currentTrack?.artist ?? "Unknown Artist")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)

            // Progress Slider
            HStack(spacing: 16) {
                Text(formatDuration(isDragging ? dragTime : player.currentTime))
                    .font(.caption).monospacedDigit().foregroundColor(AppColors.textPrimary)
                
                Slider(value: Binding(
                    get: { isDragging ? dragTime : player.currentTime },
                    set: { dragTime = $0 }
                ), in: 0...(player.duration > 0 ? player.duration : 1)) { dragging in
                    isDragging = dragging
                    if !dragging { player.seek(to: dragTime) }
                }
                .accentColor(AppColors.textPrimary)
                
                Text(formatDuration(player.duration))
                    .font(.caption).monospacedDigit().foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, 24).padding(.top, 48)

            Spacer()

            // Playback Controls
            HStack(spacing: 0) {
                Button(action: { showLyrics = true }) {
                    Image(systemName: "quote.bubble")
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                        .skeuoRaised(cornerRadius: 22)
                }
                Spacer()
                Button(action: { player.skipPrevious() }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 56, height: 56)
                        .skeuoRaised(cornerRadius: 28)
                }
                Spacer()
                Button(action: { player.togglePlayPause() }) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 72, height: 72)
                        .skeuoRaised(cornerRadius: 36)
                }
                Spacer()
                Button(action: { player.skipNext() }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 56, height: 56)
                        .skeuoRaised(cornerRadius: 28)
                }
                Spacer()
                Button(action: { player.togglePlaybackMode() }) {
                    Image(systemName: player.playbackMode.iconName)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 44, height: 44)
                        .skeuoRaised(cornerRadius: 22)
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
