import SwiftUI

struct BottomControlsView: View {
    @StateObject private var player = MusicPlayer.shared
    
    // Figma 1:1 标尺
    private let buttonSize: CGFloat = 72
    private let playButtonSize: CGFloat = 88
    private let spacing: CGFloat = 32
    
    var body: some View {
        HStack(spacing: spacing) {
            // Previous
            Button(action: { player.skipPrevious() }) {
                ControlIcon(name: "backward.fill", size: 20)
            }
            .buttonStyle(SkeuoButtonStyle(size: buttonSize))
            
            // Play/Pause
            Button(action: { player.togglePlayPause() }) {
                ControlIcon(name: player.isPlaying ? "pause.fill" : "play.fill", size: 28)
            }
            .buttonStyle(SkeuoButtonStyle(size: playButtonSize))
            
            // Next
            Button(action: { player.skipNext() }) {
                ControlIcon(name: "forward.fill", size: 20)
            }
            .buttonStyle(SkeuoButtonStyle(size: buttonSize))
        }
    }
}

struct ControlIcon: View {
    let name: String
    let size: CGFloat
    
    var body: some View {
        Image(systemName: name)
            .font(.system(size: size, weight: .black))
            .foregroundColor(AppColors.textPrimary)
    }
}

// MARK: - 1:1 拟物化按钮样式
struct SkeuoButtonStyle: ButtonStyle {
    let size: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(
                ZStack {
                    if configuration.isPressed {
                        Circle()
                            .fill(AppColors.background)
                            .skeuoSunken(cornerRadius: size / 2)
                    } else {
                        Circle()
                            .fill(AppColors.background)
                            .skeuoRaised(cornerRadius: size / 2)
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
