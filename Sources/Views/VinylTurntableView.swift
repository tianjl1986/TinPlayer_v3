import SwiftUI

struct VinylTurntableView: View {
    @StateObject private var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    
    // Figma 1:1 精确几何参数 (基于 390x844 标准稿)
    private let baseWidth: CGFloat = 342
    private let baseHeight: CGFloat = 400
    private let platterSize: CGFloat = 310
    private let recordSize: CGFloat = 290
    private let spindleSize: CGFloat = 14
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 1. 底座 (Turntable Base) - 9880:14740
            // Figma: x:24, y:92, w:342, h:400
            Image("turntable_base_light")
                .resizable()
                .frame(width: baseWidth, height: baseHeight)
                .skeuoRaised(cornerRadius: 32)
            
            // 2. 托盘 (Platter) - 9880:14763
            // Figma: relX:16, relY:45, w:310, h:310
            Image("platter_light")
                .resizable()
                .frame(width: platterSize, height: platterSize)
                .skeuoSunken(cornerRadius: platterSize / 2)
                .position(x: 16 + platterSize / 2, y: 45 + platterSize / 2)
            
            // 3. 黑胶唱片 (Vinyl Record Group) - 9970:15678
            // Figma: relX:26, relY:55, w:290, h:290
            ZStack {
                Image("vinyl_record_light")
                    .resizable()
                    .frame(width: recordSize, height: recordSize)
                    .overlay(
                        DesignTokens.vinylGradient
                            .opacity(0.3)
                    )
                
                // 唱片中心标签 (Daft Punk Cover) - 9927:15066
                // Figma: w:134.8, h:134.8 (约 135)
                if let track = player.currentTrack {
                    AsyncImage(url: URL(string: track.coverUrl)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 135, height: 135)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                }
            }
            .rotationEffect(.degrees(rotation))
            .position(x: 26 + recordSize / 2, y: 55 + recordSize / 2)
            
            // 4. 中心轴 (Spindle) - 9889:14767
            // Figma: relX:164, relY:193, w:14, h:14
            Image("spindle_light")
                .resizable()
                .frame(width: spindleSize, height: spindleSize)
                .background(DesignTokens.spindleGradient.clipShape(Circle()))
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 4, y: 4)
                .position(x: 164 + spindleSize / 2, y: 193 + spindleSize / 2)
            
            // 5. 唱臂组件 (Tonearm Assembly) - 9893:14773
            // Figma: relX:173.7, relY:13.5, w:160.7, h:160.7
            ZStack(alignment: .topTrailing) {
                // 唱臂底座 (arm_base_light)
                Image("arm_base_light")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .skeuoRaised(cornerRadius: 40)
                    .position(x: 80, y: 40) // 位于组件右上角
                
                // 唱臂主体 (tonearm_light)
                Image("tonearm_light")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140) // 调整至视觉比例
                    .rotationEffect(.degrees(player.isPlaying ? 28 : 0), anchor: .topTrailing)
                    .offset(x: 20, y: 10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 5, y: 5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: player.isPlaying)
            }
            .frame(width: 160, height: 160)
            .position(x: 173.7 + 80, y: 13.5 + 80)
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
        // 保持当前角度逻辑可后续添加
    }
}
