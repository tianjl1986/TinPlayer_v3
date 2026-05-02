import SwiftUI

struct BottomControlsView: View {
    @StateObject private var player = MusicPlayer.shared
    @State private var showLyrics = false
    @State private var showQueue = false
    
    // Figma 1:1 标尺
    private let sideButtonSize: CGFloat = 40 // Lyrics/Queue
    private let navButtonSize: CGFloat = 56  // Prev/Next
    private let playButtonSize: CGFloat = 72 // Play
    private let spacing: CGFloat = 20
    
    var body: some View {
        HStack(spacing: spacing) {
            // 1. Lyrics Toggle - 9880:14749
            Button(action: { showLyrics.toggle() }) {
                Text("LRC")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .buttonStyle(SkeuoButtonStyle(size: sideButtonSize, cornerRadius: 20))
            
            // 2. Prev - 9880:14751
            Button(action: { player.skipPrevious() }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
            }
            .buttonStyle(SkeuoButtonStyle(size: navButtonSize, cornerRadius: 28))
            
            // 3. Play - 9880:14753
            Button(action: { player.togglePlayPause() }) {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
            }
            .buttonStyle(SkeuoButtonStyle(size: playButtonSize, cornerRadius: 36))
            
            // 4. Next - 9880:14755
            Button(action: { player.skipNext() }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
            }
            .buttonStyle(SkeuoButtonStyle(size: navButtonSize, cornerRadius: 28))
            
            // 5. Queue - 9880:14757
            Button(action: { showQueue.toggle() }) {
                Text("Q")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .buttonStyle(SkeuoButtonStyle(size: sideButtonSize, cornerRadius: 20))
        }
    }
}

// MARK: - 1:1 拟物化按钮样式
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
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
