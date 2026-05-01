import SwiftUI

struct VinylTurntableView: View {
    let rotation: Double
    let isPlaying: Bool
    @Environment(\.colorScheme) var colorScheme
    
    private var vinylImage: String { colorScheme == .dark ? "vinyl_record_dark" : "vinyl_record_light" }
    private var tonearmImage: String { colorScheme == .dark ? "tonearm_dark" : "tonearm_light" }
    private var baseImage: String { colorScheme == .dark ? "turntable_base_dark" : "turntable_base_light" }

    var body: some View {
        ZStack {
            // 1. 底座 (固定背景)
            Image(baseImage)
                .resizable()
                .scaledToFit()
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // 2. 黑胶唱片 (旋转动画)
            Image(vinylImage)
                .resizable()
                .scaledToFit()
                .padding(42) // 留出边缘空间
                .rotationEffect(.degrees(rotation))
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            
            // 3. 唱臂 (根据播放状态旋转角度)
            Image(tonearmImage)
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(isPlaying ? 28 : 0), anchor: .topTrailing)
                .offset(x: 50, y: -10) // 精确微调位置
                .animation(.interpolatingSpring(stiffness: 50, damping: 8), value: isPlaying)
        }
        .padding(20)
    }
}
