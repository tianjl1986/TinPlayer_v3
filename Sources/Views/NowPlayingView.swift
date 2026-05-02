import SwiftUI

struct NowPlayingView: View {
    @StateObject private var player = MusicPlayer.shared
    @State private var isLyricsPresented = false
    @State private var isDragging = false
    @State private var dragProgress: Double = 0
    @Environment(\.presentationMode) var presentationMode
    
    private var displayProgress: Double {
        isDragging ? dragProgress : (player.duration > 0 ? player.currentTime / player.duration : 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(
                title: "NOW PLAYING",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { isLyricsPresented.toggle() }) {
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(10)
                            .skeuoRaised(cornerRadius: 10)
                    }
                )
            )
            
            Spacer()
            
            // Vinyl Player Section
            VinylTurntableView()
                .frame(height: 380)
                .padding(.vertical, 20)
            
            // Track Info
            VStack(spacing: 8) {
                Text(player.currentTrack?.title ?? "Not Playing")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(player.currentTrack?.artist ?? "Select a track to start")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Progress Bar
            VStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppColors.textSecondary.opacity(0.1)).frame(height: 4)
                        Capsule().fill(AppColors.textPrimary).frame(width: geo.size.width * CGFloat(displayProgress), height: 4)
                        Circle().fill(AppColors.textPrimary).frame(width: 14, height: 14)
                            .offset(x: geo.size.width * CGFloat(displayProgress) - 7)
                    }
                    .contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            dragProgress = min(max(0, value.location.x / geo.size.width), 1)
                        }
                        .onEnded { _ in
                            player.seek(to: dragProgress * player.duration)
                            isDragging = false
                        }
                    )
                }
                .frame(height: 14)
                
                HStack {
                    Text(formatDuration(isDragging ? dragProgress * player.duration : player.currentTime))
                    Spacer()
                    Text(formatDuration(player.duration))
                }
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 32)
            
            // Controls
            HStack(spacing: 40) {
                Button(action: { player.togglePlaybackMode() }) {
                    Image(systemName: player.playbackMode.iconName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(player.playbackMode != .list ? AppColors.textActive : AppColors.textPrimary)
                }
                
                Button(action: { player.skipPrevious() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(20)
                        .skeuoRaised(cornerRadius: 32)
                }
                
                Button(action: { player.togglePlayPause() }) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(24)
                        .skeuoRaised(cornerRadius: 40)
                }
                
                Button(action: { player.skipNext() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(20)
                        .skeuoRaised(cornerRadius: 32)
                }
                
                Button(action: { /* More/Menu */ }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(AppColors.background.ignoresSafeArea())
        .sheet(isPresented: $isLyricsPresented) {
            LyricsView()
        }
    }
}
