import SwiftUI

struct NowPlayingView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Figma 1:1 标尺
    private let itemSpacing: CGFloat = 32
    
    var body: some View {
        VStack(spacing: itemSpacing) {
            // 1. Header (1:1 还原) - 9880:14736
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                }
                
                Spacer()
                
                Text("NOW PLAYING")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                
                Spacer()
                
                Button(action: { /* More action */ }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // 2. 黑胶唱机 (核心拟物组件) - 9880:14740
            VinylTurntableView()
                .frame(maxWidth: .infinity)
            
            // 3. 歌曲信息 (1:1 字体) - 9880:14741
            VStack(spacing: 8) {
                Text(player.currentTrack?.title ?? "Instant Crush")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                    .lineLimit(1)
                
                Text(player.currentTrack?.artist ?? "Daftpunk")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 24)
            
            // 4. 进度条 (拟物化槽位) - 9880:14744
            HStack(spacing: 16) {
                Text(formatDuration(player.currentTime))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
                
                // 进度条背景槽 (Sunken)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(DesignTokens.surfaceMain)
                        .skeuoSunken(cornerRadius: 4)
                        .frame(height: 8)
                    
                    // 进度条填充 (Active)
                    Capsule()
                        .fill(Color(hexString: "#404040")) // Match Figma "Progress Fill"
                        .frame(width: max(0, CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)) * 200), height: 8)
                }
                
                Text(formatDuration(player.duration))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .padding(.horizontal, 24)
            
            // 5. 控制面板 (像素级对齐) - 9880:14748
            BottomControlsView()
                .padding(.bottom, 48)
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
    }
}

private func formatDuration(_ seconds: TimeInterval) -> String {
    let minutes = Int(seconds) / 60
    let remainingSeconds = Int(seconds) % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
}
