import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 🚀 1. 唱机机身底座 (Turntable Base) - 1:1 Figma 9880:14740
            RoundedRectangle(cornerRadius: 32)
                .fill(AppColors.background)
                .frame(width: 380, height: 380)
                .skeuoRaised(cornerRadius: 32)
                .overlay(
                    // 模拟拉丝金属质感 (Brushed Metal)
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            // 🚀 2. 唱盘下沉区 (Platter Well)
            Circle()
                .fill(AppColors.background)
                .frame(width: 340, height: 340)
                .skeuoSunken(cornerRadius: 170)
            
            // 🚀 3. 金属转盘边缘 (Metal Ring)
            Circle()
                .stroke(
                    LinearGradient(colors: [Color(hex: "#d1d1d6"), Color(hex: "#f4f4f5"), Color(hex: "#a1a1aa"), Color(hex: "#71717a")], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 6
                )
                .frame(width: 326, height: 326)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 1, y: 1)
            
            // 🚀 4. 黑胶唱片主体 (Vinyl Record)
            ZStack {
                // 唱片盘面材质 (Angular Gradient 模拟真实反射)
                Circle()
                    .fill(
                        AngularGradient(gradient: Gradient(colors: [
                            Color(hex: "#09090b"), Color(hex: "#18181b"),
                            Color(hex: "#27272a"), Color(hex: "#09090b"),
                            Color(hex: "#1a1a1a"), Color(hex: "#09090b")
                        ]), center: .center)
                    )
                    .frame(width: 320, height: 320)
                
                // 唱片沟槽 (Grooves)
                ForEach(0..<40) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.03), lineWidth: 0.5)
                        .frame(width: CGFloat(320 - (i * 4)), height: CGFloat(320 - (i * 4)))
                }

                // 专辑封面标签 (Label)
                ZStack {
                    if let track = player.currentTrack,
                       let album = MusicLibraryService.shared.albums.first(where: { $0.tracks.contains(where: { $0.id == track.id }) }),
                       let image = album.coverImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 130, height: 130)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 130, height: 130)
                    }
                    
                    // 中心主轴 (Spindle)
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "#e5e7eb"), Color(hex: "#9ca3af")], startPoint: .top, endPoint: .bottom))
                        .frame(width: 16, height: 16)
                        .skeuoRaised(cornerRadius: 8)
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 🚀 5. 高级拟物化唱臂 (Premium Tonearm)
            TonearmView(isPlaying: player.isPlaying)
                .offset(x: 130, y: -130)
        }
        .onReceive(timer) { _ in
            if player.isPlaying {
                rotation = (rotation + 0.8).truncatingRemainder(dividingBy: 360)
            }
        }
    }
}

struct TonearmView: View {
    let isPlaying: Bool
    var body: some View {
        ZStack(alignment: .top) {
            // 枢轴底座 (Pivot Base)
            ZStack {
                Circle()
                    .fill(AppColors.background)
                    .frame(width: 64, height: 64)
                    .skeuoRaised(cornerRadius: 32)
                
                Circle()
                    .stroke(Color(hex: "#a1a1aa"), lineWidth: 1)
                    .frame(width: 40, height: 40)
            }
            
            // 唱臂杆 (Arm)
            VStack(spacing: 0) {
                // 配重块 (Counterweight)
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [Color(hex: "#71717a"), Color(hex: "#3f3f46")], startPoint: .top, endPoint: .bottom))
                    .frame(width: 20, height: 30)
                    .offset(y: -15)
                
                // 唱臂主体
                Rectangle()
                    .fill(
                        LinearGradient(colors: [
                            Color(hex: "#e5e7eb"), Color(hex: "#d1d5db"),
                            Color(hex: "#9ca3af"), Color(hex: "#4b5563")
                        ], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 8, height: 200)
                    .cornerRadius(4)
                
                // 唱头壳 (Headshell)
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#18181b"))
                        .frame(width: 18, height: 36)
                    
                    // 针头 (Stylus)
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 2, height: 6)
                        .offset(y: 4)
                }
                .offset(x: -6)
            }
            .rotationEffect(.degrees(isPlaying ? 26 : 0), anchor: .top)
            .offset(y: 32)
        }
    }
}
