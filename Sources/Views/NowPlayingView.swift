import SwiftUI

struct NowPlayingView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header (Using AppHeader for consistency)
            AppHeader(
                title: "NOW PLAYING",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(DesignTokens.textActive)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { /* More */ }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            .padding(.horizontal, 24)
            
            Spacer().frame(height: 20)
            
            // 2. Turntable Area
            VinylTurntableView()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            
            Spacer().frame(height: 40)
            
            // 3. Track Info
            VStack(spacing: 12) {
                Text(player.currentTrack?.title ?? "SKEUOMORPHIC DREAMS")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                
                Text(player.currentTrack?.artist ?? "THE VINYL ORCHESTRA")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 40)
            
            Spacer().frame(height: 40)
            
            // 4. Progress Bar (Figma Style: Sunken and Slanted)
            VStack(spacing: 8) {
                HStack {
                    Text(formatDuration(player.currentTime))
                    Spacer()
                    Text(formatDuration(player.duration))
                }
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(DesignTokens.textSecondary)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Track
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 12)
                            .skeuoSunken(cornerRadius: 6)
                        
                        // Fill
                        RoundedRectangle(cornerRadius: 6)
                            .fill(DesignTokens.textPrimary.opacity(0.8))
                            .frame(width: geo.size.width * CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)), height: 12)
                    }
                }
                .frame(height: 12)
            }
            .padding(.horizontal, 32)
            
            Spacer().frame(height: 50)
            
            // 5. Controls
            BottomControlsView()
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
