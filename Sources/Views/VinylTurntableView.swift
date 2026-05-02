import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 🚀 1. 唱机底座下沉槽 (Figma 9880:14735)
            Circle()
                .fill(AppColors.background)
                .frame(width: 340, height: 340)
                .skeuoSunken(cornerRadius: 170)
            
            // 🚀 2. 金属转盘边缘 (Metal Ring)
            Circle()
                .stroke(
                    LinearGradient(colors: [Color(hex: "#d1d1d6"), Color(hex: "#f4f4f5"), Color(hex: "#a1a1aa")], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 4
                )
                .frame(width: 326, height: 326)
            
            // 🚀 3. 黑胶唱片主体
            ZStack {
                // 唱片盘面材质 (Angular Gradient 模拟反射)
                Circle()
                    .fill(
                        AngularGradient(gradient: Gradient(colors: [
                            Color(hex: "#09090b"), Color(hex: "#18181b"),
                            Color(hex: "#27272a"), Color(hex: "#09090b")
                        ]), center: .center)
                    )
                    .frame(width: 320, height: 320)
                    .shadow(color: Color.black.opacity(0.5), radius: 15, x: 0, y: 10)

                // 唱片细纹 (精细化)
                ForEach(0..<20) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.04), lineWidth: 0.5)
                        .frame(width: CGFloat(320 - (i * 8)), height: CGFloat(320 - (i * 8)))
                }

                // 专辑封面标签
                ZStack {
                    if let track = player.currentTrack,
                       let album = MusicLibraryService.shared.albums.first(where: { $0.tracks.contains(where: { $0.id == track.id }) }),
                       let image = album.coverImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 140, height: 140)
                    }
                    
                    // 中心主轴
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "#a1a1aa"), Color(hex: "#d4d4d8")], startPoint: .top, endPoint: .bottom))
                        .frame(width: 12, height: 12)
                        .shadow(radius: 1)
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 🚀 4. 拟物化唱臂 (Tonearm)
            TonearmView(isPlaying: player.isPlaying)
                .offset(x: 110, y: -130)
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
            // 枢轴底座
            Circle()
                .fill(AppColors.background)
                .frame(width: 54, height: 54)
                .skeuoRaised(cornerRadius: 27)
            
            // 唱臂杆
            VStack(spacing: 0) {
                // 唱臂主体
                Rectangle()
                    .fill(LinearGradient(colors: [Color(hex: "#d4d4d8"), Color(hex: "#71717a")], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 6, height: 180)
                    .cornerRadius(3)
                
                // 唱头
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "#18181b"))
                    .frame(width: 12, height: 24)
                    .offset(x: -4)
            }
            .rotationEffect(.degrees(isPlaying ? 28 : 0), anchor: .top)
            .offset(y: 10)
        }
    }
}
