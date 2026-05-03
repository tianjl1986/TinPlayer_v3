import SwiftUI

struct BottomControlsView: View {
    @ObservedObject var player = MusicPlayer.shared
    @Binding var showLyrics: Bool
    
    // Figma 1:1 标尺
    private let sideButtonSize: CGFloat = 44
    private let navButtonSize: CGFloat = 56
    private let playButtonSize: CGFloat = 72
    private let spacing: CGFloat = 20
    
    var body: some View {
        HStack(spacing: spacing) {
            // 1. Lyrics Toggle
            Button(action: { showLyrics.toggle() }) {
                Text("LRC")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(showLyrics ? DesignTokens.textActive : DesignTokens.textSecondary)
            }
            .buttonStyle(SkeuoButtonStyle(size: sideButtonSize, cornerRadius: 22))
            
            // 2. Prev
            Button(action: { player.skipPrevious() }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
            }
            .buttonStyle(SkeuoButtonStyle(size: navButtonSize, cornerRadius: 28))
            
            // 3. Play/Pause
            Button(action: { player.togglePlayPause() }) {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
            }
            .buttonStyle(SkeuoButtonStyle(size: playButtonSize, cornerRadius: 36))
            
            // 4. Next
            Button(action: { player.skipNext() }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
            }
            .buttonStyle(SkeuoButtonStyle(size: navButtonSize, cornerRadius: 28))
            
            // 5. Play Mode (Cycle through List, Loop, Shuffle)
            Button(action: { player.togglePlaybackMode() }) {
                Image(systemName: player.playbackMode.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .buttonStyle(SkeuoButtonStyle(size: sideButtonSize, cornerRadius: 22))
        }
    }
}

struct SkeuoButtonStyle: ButtonStyle {
    let size: CGFloat
    let cornerRadius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(
                ZStack {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(DesignTokens.surfaceMain)
                            .skeuoSunken(cornerRadius: cornerRadius)
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(DesignTokens.surfaceMain)
                            .skeuoRaised(cornerRadius: cornerRadius)
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}
