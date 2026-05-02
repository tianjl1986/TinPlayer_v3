import SwiftUI

struct NowPlayingView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showLyrics = false
    @State private var dragProgress: Double = 0
    @State private var isDragging = false
    
    var displayProgress: Double {
        isDragging ? dragProgress : (player.duration > 0 ? player.playbackTime / player.duration : 0)
    }
    
    var body: some View {
        ZStack {
            // Main Playing View
            VStack(spacing: 0) {
                // Header (Floating Style)
                AppHeader(
                    title: "正在播放",
                    leftItem: AnyView(
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                                .padding(10)
                        }
                    ),
                    rightItem: AnyView(
                        Button(action: { showLyrics = true }) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                                .padding(10)
                        }
                    )
                )
                
                Spacer(minLength: 10)
                
                // Turntable (All Assets)
                VinylTurntableView()
                    .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                
                Spacer(minLength: 20)
                
                // Info
                VStack(spacing: 8) {
                    Text(player.currentTrack?.title ?? "未在播放")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(player.currentTrack?.artist ?? "Artist")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Progress
                VStack(spacing: 12) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.black.opacity(0.1)).frame(height: 4)
                            Capsule().fill(AppColors.textPrimary).frame(width: geo.size.width * CGFloat(displayProgress), height: 4)
                            Circle().fill(AppColors.textPrimary).frame(width: 14, height: 14)
                                .offset(x: geo.size.width * CGFloat(displayProgress) - 7)
                        }
                        .contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                            isDragging = true
                            dragProgress = Double(min(max(0, v.location.x / geo.size.width), 1))
                        }.onEnded { _ in
                            player.seek(to: player.duration * dragProgress)
                            isDragging = false
                        })
                    }
                    .frame(height: 14)
                    
                    HStack {
                        Text(timeString(time: isDragging ? dragProgress * player.duration : player.playbackTime))
                        Spacer()
                        Text("-" + timeString(time: max(0, player.duration - (isDragging ? dragProgress * player.duration : player.playbackTime))))
                    }
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)
                
                Spacer(minLength: 20)
                
                // Controls (Skeuomorphic)
                HStack(spacing: 24) {
                    Button(action: { player.toggleShuffleMode() }) {
                        Text("LRC").font(.system(size: 11, weight: .black))
                            .foregroundColor(player.shuffleMode != .off ? AppColors.textActive : AppColors.textPrimary)
                            .frame(width: 48, height: 48).skeuoRaised(cornerRadius: 24)
                    }
                    
                    HStack(spacing: 30) {
                        Button(action: { player.skipPrevious() }) {
                            Image(systemName: "backward.end.fill").font(.system(size: 20))
                                .frame(width: 64, height: 64).skeuoRaised(cornerRadius: 32)
                        }
                        Button(action: { player.togglePlayPause() }) {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill").font(.system(size: 28))
                                .frame(width: 88, height: 88).skeuoRaised(cornerRadius: 44)
                        }
                        Button(action: { player.skipNext() }) {
                            Image(systemName: "forward.end.fill").font(.system(size: 20))
                                .frame(width: 64, height: 64).skeuoRaised(cornerRadius: 32)
                        }
                    }
                    .foregroundColor(AppColors.textPrimary)
                    
                    Button(action: { player.toggleRepeatMode() }) {
                        Text("Q").font(.system(size: 11, weight: .black))
                            .foregroundColor(player.repeatMode != .none ? AppColors.textActive : AppColors.textPrimary)
                            .frame(width: 48, height: 48).skeuoRaised(cornerRadius: 24)
                    }
                }
                .padding(.bottom, 40)
            }
            .background(AppColors.background.ignoresSafeArea())
            
            // Lyrics Overlay
            if showLyrics {
                LyricsView(showLyrics: $showLyrics)
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
    }
    
    private func timeString(time: Double) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct LyricsView: View {
    @Binding var showLyrics: Bool
    @StateObject var player = MusicPlayer.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(
                title: "LYRICS / 歌词",
                leftItem: AnyView(
                    Button(action: { showLyrics = false }) {
                        Image(systemName: "chevron.down").font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary).padding(10)
                    }
                ),
                rightItem: AnyView(Color.clear.frame(width: 40))
            )
            
            // Top Knobs (Physical Assets)
            HStack {
                Image("knob").resizable().aspectRatio(contentMode: .fit).frame(width: 52, height: 52)
                Spacer()
                RoundedRectangle(cornerRadius: 3).fill(Color.black.opacity(0.8)).frame(height: 6).padding(.horizontal, -15)
                Spacer()
                Image("knob").resizable().aspectRatio(contentMode: .fit).frame(width: 52, height: 52)
            }
            .padding(.horizontal, 24).padding(.top, 10)
            
            // Lyrics Paper Panel
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 20) {
                    Text(player.currentTrack?.title ?? "Title").font(.system(size: 18, weight: .black))
                    Text(player.currentTrack?.artist ?? "Artist").font(.system(size: 14, weight: .bold)).foregroundColor(.gray)
                    
                    ScrollView(showsIndicators: false) {
                        Text("Lyrics content goes here...\n(1:1 Design Restoration Mode)")
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .padding(.top, 40)
                    }
                }
                .padding(30)
            }
            .padding(.horizontal, 24).padding(.top, 10).padding(.bottom, 40)
            
            Spacer()
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
