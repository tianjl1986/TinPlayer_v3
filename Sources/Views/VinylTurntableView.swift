import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @State private var rotationAngle: Double = 0
    
    // Figma 导出的切片资产：
    // - turntable_base: 唱机底座
    // - platter: 转盘
    // - tonearm: 唱臂
    
    var body: some View {
        ZStack {
            // 1. 唱机底座 (Base)
            Image("turntable_base")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
            
            // 2. 旋转转盘 + 专辑封面 (Platter & Cover)
            ZStack {
                Image("platter")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                // 专辑封面
                if let cover = player.currentTrack?.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: UIScreen.main.bounds.width * 0.45)
                } else {
                    Circle()
                        .fill(Color.black.opacity(0.8))
                        .frame(width: UIScreen.main.bounds.width * 0.45)
                }
                
                // 唱片中心装饰
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 20, height: 20)
            }
            .frame(width: UIScreen.main.bounds.width * 0.72)
            .offset(x: -25, y: 0) // 根据 Figma 稿件调整转盘位置
            .rotationEffect(.degrees(rotationAngle))
            
            // 3. 唱臂 (Tonearm)
            Image("tonearm")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.3)
                .rotationEffect(.degrees(player.isPlaying ? 25 : 0), anchor: .topTrailing)
                .offset(x: 100, y: -120) // 根据 Figma 稿件调整唱臂支点位置
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: player.isPlaying)
        }
        .padding(20)
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            if player.isPlaying {
                rotationAngle += 2 // 33 1/3 RPM 模拟
            }
        }
    }
}
