import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 🚀 1:1 还原黑胶唱片 (Figma 9880:14735)
            // 唱片主体：320x320
            ZStack {
                Circle()
                    .fill(Color(hex: "#09090b")) // 深黑胶色
                    .frame(width: 320, height: 320)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)

                // 唱片细纹纹路
                ForEach(0..<15) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.03), lineWidth: 1)
                        .frame(width: CGFloat(320 - (i * 12)), height: CGFloat(320 - (i * 12)))
                }

                // 专辑封面标签：140x140
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
                        Image(systemName: "music.note")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                    
                    // 中心圆孔
                    Circle()
                        .fill(AppColors.background)
                        .frame(width: 12, height: 12)
                        .skeuoSunken(cornerRadius: 6)
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 唱针定位
            TonearmView(isPlaying: player.isPlaying)
                .offset(x: 100, y: -140)
        }
        .onReceive(timer) { _ in
            if player.isPlaying {
                rotation = (rotation + 1.0).truncatingRemainder(dividingBy: 360)
            }
        }
    }
}

struct TonearmView: View {
    let isPlaying: Bool
    var body: some View {
        ZStack(alignment: .top) {
            // 枢轴
            Circle()
                .fill(AppColors.background)
                .frame(width: 40, height: 40)
                .skeuoRaised(cornerRadius: 20)
            
            // 唱臂
            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: "#a1a1aa"), Color(hex: "#71717a")], startPoint: .top, endPoint: .bottom))
                .frame(width: 4, height: 160)
                .cornerRadius(2)
                .rotationEffect(.degrees(isPlaying ? 25 : 0), anchor: .top)
                .offset(y: 20)
        }
    }
}
