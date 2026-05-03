import SwiftUI

struct VinylTurntableView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @State private var rotation: Double = 0
    
    // Figma 1:1 精确几何参数 (基于 390x844 标准稿)
    private let baseWidth: CGFloat = 342
    private let baseHeight: CGFloat = 400
    private let platterSize: CGFloat = 310
    private let recordSize: CGFloat = 290
    private let spindleSize: CGFloat = 14
    
    var body: some View {
        ZStack {
            // 1. 底座 (Turntable Base) - 9880:14740
            RoundedRectangle(cornerRadius: 32)
                .fill(DesignTokens.surfaceMain)
                .skeuoRaised(cornerRadius: 32)
                .frame(width: baseWidth, height: baseHeight)
            
            // 2. 托盘 (Platter) - 9880:14763
            // 居中于 Base (171, 200)
            Circle()
                .fill(DesignTokens.surfaceMain)
                .skeuoSunken(cornerRadius: platterSize / 2)
                .frame(width: platterSize, height: platterSize)
            
            // 3. 黑胶唱片 (Vinyl Record Group) - 9970:15678
            ZStack {
                // 唱片本体 (vinyl_record_light)
                Circle()
                    .fill(DesignTokens.vinylGradient)
                    .frame(width: recordSize, height: recordSize)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.8), lineWidth: 0.5)
                    )
                
                // 唱片纹理 (Grooves)
                ForEach(0..<4) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        .frame(width: recordSize - CGFloat(i * 40 + 20))
                }
                
                // 唱片中心标签 (Album Cover) - 9927:15066
                if let track = player.currentTrack {
                    let album = libraryService.albums.first(where: { $0.tracks.contains(track) })
                    if let cover = album?.coverImage {
                        Image(uiImage: cover)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 135, height: 135)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 135, height: 135)
                    }
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 135, height: 135)
                }
                
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    .frame(width: 135, height: 135)
            }
            .rotationEffect(.degrees(rotation))
            
            // 4. 中心轴 (Spindle) - 9889:14767
            Circle()
                .fill(DesignTokens.spindleGradient)
                .frame(width: spindleSize, height: spindleSize)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 4, y: 4)
            
            // 5. 唱臂组件 (Tonearm Assembly) - 9893:14773
            // 唱臂需要基于底座右上角定位
            ZStack(alignment: .topTrailing) {
                // 唱臂底座 (arm_base_light)
                Circle()
                    .fill(DesignTokens.surfaceMain)
                    .skeuoRaised(cornerRadius: 40)
                    .frame(width: 80, height: 80)
                    .offset(x: -20, y: 20)
                
                // 唱臂主体 (tonearm_light)
                Image("tonearm_light") // 假设已导入资源，否则用占位
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140)
                    .rotationEffect(.degrees(player.isPlaying ? 28 : 0), anchor: .topTrailing)
                    .offset(x: -10, y: 30)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: player.isPlaying)
            }
            .frame(width: baseWidth, height: baseHeight)
        }
        .frame(width: baseWidth, height: baseHeight)
        .onAppear {
            if player.isPlaying { startRotation() }
        }
        .onChange(of: player.isPlaying) { isPlaying in
            if isPlaying {
                startRotation()
            } else {
                stopRotation()
            }
        }
    }
    
    private func startRotation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotation += 360
        }
    }
    
    private func stopRotation() {
        // Stop animation logic
    }
}
    
    private func startRotation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotation += 360
        }
    }
    
    private func stopRotation() {
        // 保持当前角度逻辑可后续添加
    }
}
