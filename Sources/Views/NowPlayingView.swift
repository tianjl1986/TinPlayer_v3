import SwiftUI

struct NowPlayingView: View {
    @StateObject private var player = MusicPlayer.shared
    @State private var showLyrics = false
    @Environment(\.presentationMode) var presentationMode
    
    // Figma 1:1 标尺
    private let vSpacing: CGFloat = 40
    private let controlSectionHeight: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header (1:1 还原)
            AppHeader(
                title: "NOW PLAYING",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                            .padding(12)
                            .skeuoRaised(cornerRadius: 12)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { showLyrics = true }) {
                        Image(systemName: "quote.bubble.fill")
                            .font(.system(size: 16))
                            .foregroundColor(DesignTokens.textPrimary)
                            .padding(12)
                            .skeuoRaised(cornerRadius: 12)
                    }
                )
            )
            
            // 2. 黑胶唱机 (核心拟物组件)
            // 它是页面的视觉中心，高度自适应但保持黄金比例偏�?            VinylTurntableView()
                .padding(.top, 20)
            
            Spacer(minLength: 20)
            
            // 3. 歌曲信息 (1:1 字体)
            VStack(spacing: 8) {
                Text(player.currentTrack?.title ?? "No Track")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                    .lineLimit(1)
                
                Text(player.currentTrack?.artist ?? "Unknown Artist")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 40)
            
            Spacer(minLength: 30)
            
            // 4. 进度�?(拟物化槽�?
            VStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    // 进度条背景槽 (Sunken)
                    Capsule()
                        .fill(DesignTokens.background)
                        .skeuoSunken(cornerRadius: 3)
                        .frame(height: 6)
                    
                    // 进度条填�?(Active)
                    Capsule()
                        .fill(DesignTokens.textActive)
                        .frame(width: CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)) * (UIScreen.main.bounds.width - 80), height: 6)
                    
                    // 滑块 (Handle)
                    Circle()
                        .fill(DesignTokens.textPrimary)
                        .frame(width: 14, height: 14)
                        .skeuoRaised(cornerRadius: 7)
                        .offset(x: CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)) * (UIScreen.main.bounds.width - 80) - 7)
                }
                
                HStack {
                    Text(formatDuration(player.currentTime))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                    Spacer()
                    Text(formatDuration(player.duration))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                }
                .foregroundColor(DesignTokens.textSecondary)
            }
            .padding(.horizontal, 40)
            
            Spacer(minLength: 40)
            
            // 5. 控制面板 (像素级对�?
            BottomControlsView()
                .padding(.bottom, 50)
        }
        .background(DesignTokens.background.ignoresSafeArea())
        .sheet(isPresented: $showLyrics) {
            LyricsView()
        }
    }
}
