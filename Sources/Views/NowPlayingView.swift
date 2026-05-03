import SwiftUI

struct NowPlayingView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header - Standardized
            AppHeader(
                title: "NOW PLAYING",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { /* More */ }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            // 2. Turntable Area - Fixed container to prevent growing animation
            VStack {
                Spacer(minLength: 0)
                VinylTurntableView()
                    .padding(.horizontal, 24)
                Spacer(minLength: 0)
            }
            .frame(height: 380) // Lock height to prevent jitter
            
            // 3. Track Info
            VStack(spacing: 8) {
                Text(player.currentTrack?.title ?? "SKEUOMORPHIC DREAMS")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                    .lineLimit(1)
                
                Text(player.currentTrack?.artist ?? "THE VINYL ORCHESTRA")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer(minLength: 20)
            
            // 4. Progress Bar
            VStack(spacing: 12) {
                HStack {
                    Text(formatDuration(player.currentTime))
                    Spacer()
                    Text(formatDuration(player.duration))
                }
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(DesignTokens.textSecondary)
                
                progressBar
            }
            .padding(.horizontal, 48)
            
            Spacer(minLength: 40)
            
            // 5. Controls
            BottomControlsView()
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track: Sunken
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.1))
                    .frame(height: 8)
                    .skeuoSunken(cornerRadius: 6)
                
                // Fill: Slanted / Vivid
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [DesignTokens.textActive, DesignTokens.textActive.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)), height: 8)
                    .shadow(color: DesignTokens.textActive.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .frame(height: 8)
    }
}
