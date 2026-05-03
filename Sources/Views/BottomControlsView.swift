import SwiftUI

struct BottomControlsView: View {
    @ObservedObject var player = MusicPlayer.shared
    @Binding var showLyrics: Bool
    
    // 1:1 Design Scale
    private let sideButtonSize: CGFloat = 52
    private let navButtonSize: CGFloat = 64
    private let playButtonSize: CGFloat = 82
    private let spacing: CGFloat = 12
    
    var body: some View {
        HStack(spacing: spacing) {
            // 1. LRC Toggle
            Button(action: { 
                withAnimation(.spring()) {
                    showLyrics.toggle() 
                }
            }) {
                Text("LRC")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(showLyrics ? DesignTokens.textActive : DesignTokens.textSecondary)
            }
            .buttonStyle(SkeuoCircleButtonStyle(size: sideButtonSize))
            
            // 2. Previous (|<)
            Button(action: { player.skipPrevious() }) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DesignTokens.textPrimary)
            }
            .buttonStyle(SkeuoCircleButtonStyle(size: navButtonSize))
            
            // 3. Play/Pause (||)
            Button(action: { player.togglePlayPause() }) {
                Image(systemName: player.isPlaying ? "pause" : "play.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(DesignTokens.textPrimary)
            }
            .buttonStyle(SkeuoCircleButtonStyle(size: playButtonSize))
            
            // 4. Next (>|)
            Button(action: { player.skipNext() }) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DesignTokens.textPrimary)
            }
            .buttonStyle(SkeuoCircleButtonStyle(size: navButtonSize))
            
            // 5. Search / Queue (Q)
            Button(action: { /* Action */ }) {
                Text("Q")
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .buttonStyle(SkeuoCircleButtonStyle(size: sideButtonSize))
        }
    }
}

// MARK: - 1:1 Skeuomorphic Circle Button Style
struct SkeuoCircleButtonStyle: ButtonStyle {
    let size: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(
                ZStack {
                    if configuration.isPressed {
                        Circle()
                            .fill(DesignTokens.surfaceMain)
                            .skeuoSunken(cornerRadius: size/2)
                    } else {
                        Circle()
                            .fill(DesignTokens.surfaceMain)
                            .shadow(color: DesignTokens.skeuoShadowDark, radius: 10, x: 5, y: 5)
                            .shadow(color: DesignTokens.skeuoShadowLight, radius: 10, x: -5, y: -5)
                            .overlay(
                                Circle()
                                    .stroke(DesignTokens.skeuoShadowLight.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.interactiveSpring(), value: configuration.isPressed)
    }
}
