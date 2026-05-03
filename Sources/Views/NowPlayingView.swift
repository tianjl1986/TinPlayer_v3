import SwiftUI

struct NowPlayingView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showLyrics = false
    
    var body: some View {
        ZStack {
            DesignTokens.surfaceMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Header - Standardized
                AppHeader(
                    title: player.currentTrack?.title ?? "NOW PLAYING",
                    leftItem: AnyView(
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(DesignTokens.textPrimary)
                        }
                    )
                )
                
                // 2. Turntable Area
                ZStack {
                    VinylTurntableView(showLyrics: $showLyrics)
                }
                .frame(height: 360)
                .padding(.top, 20)
                
                // 3. Track Info
                VStack(spacing: 8) {
                    Text(player.currentTrack?.title ?? "Unknown Title")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(DesignTokens.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(player.currentTrack?.artist ?? "Unknown Artist")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(DesignTokens.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.horizontal, 40)
                .padding(.top, 32)
                
                Spacer(minLength: 20)
                
                // 4. Progress Bar
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Text(formatDuration(player.currentTime))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(DesignTokens.textSecondary)
                            .frame(width: 45, alignment: .leading)
                        
                        progressBar
                        
                        Text(formatDuration(player.duration))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(DesignTokens.textSecondary)
                            .frame(width: 45, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer(minLength: 40)
                
                // 5. Controls
                BottomControlsView(showLyrics: $showLyrics)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
            .blur(radius: showLyrics ? 20 : 0)
            .animation(.easeInOut, value: showLyrics)
            
            // 6. Lyrics Overlay (ZStack instead of Sheet)
            if showLyrics {
                LyricsView(showLyrics: $showLyrics)
                    .transition(.move(edge: .bottom))
                    .zIndex(10)
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
        .preferredColorScheme(theme.isDark ? .dark : .light) // 🚀 Force Status Bar Color
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.1))
                    .frame(height: 8)
                    .skeuoSunken(cornerRadius: 6)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [DesignTokens.textActive, DesignTokens.textActive.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)), height: 8)
            }
        }
        .frame(height: 8)
    }
}

