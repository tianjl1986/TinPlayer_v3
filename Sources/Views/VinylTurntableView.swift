import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let vinylSize = size * 0.848
            let labelSize = size * 0.395

            ZStack {
                // 1. 转盘底座
                RoundedRectangle(cornerRadius: size * 0.093)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: size, height: size)
                    .shadow(radius: 5)

                // 2. 转盘凹槽
                Circle()
                    .fill(Color.black.opacity(0.8))
                    .frame(width: size * 0.9, height: size * 0.9)

                // 3. 黑胶唱片
                ZStack {
                    Circle()
                        .fill(Color(hex: "#111111"))
                        .frame(width: vinylSize, height: vinylSize)

                    // 唱片纹路 (减少循环次数以加快编译)
                    ForEach(0..<4) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                            .frame(width: vinylSize * (0.9 - Double(i) * 0.1), height: vinylSize * (0.9 - Double(i) * 0.1))
                    }

                    // 专辑封面
                    ZStack {
                        // 使用当前曲目对应的专辑图片
                        if let track = player.currentTrack {
                            // 查找所属专辑以获取封面
                            if let album = MusicLibraryService.shared.albums.first(where: { $0.tracks.contains(where: { $0.id == track.id }) }),
                               let image = album.coverImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: labelSize, height: labelSize)
                                    .clipped()
                            } else {
                                Image(systemName: "music.note")
                                    .font(.system(size: labelSize * 0.3))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Circle().fill(Color.gray).frame(width: 10, height: 10)
                    }
                    .frame(width: labelSize, height: labelSize)
                    .background(Color.white)
                    .clipShape(Circle())
                }
                .rotationEffect(.degrees(rotation))

                // 4. 唱针
                TonearmView(isPlaying: player.isPlaying, size: size)
            }
        }
        .onReceive(timer) { _ in
            if player.isPlaying {
                rotation = (rotation + 1.5).truncatingRemainder(dividingBy: 360)
            }
        }
    }
}

struct TonearmView: View {
    let isPlaying: Bool
    let size: CGFloat
    var body: some View {
        ZStack {
            Circle().fill(Color.gray).frame(width: size * 0.1, height: size * 0.1)
                .position(x: size * 0.85, y: size * 0.15)
            
            Rectangle().fill(Color.gray)
                .frame(width: 2, height: size * 0.4)
                .rotationEffect(.degrees(isPlaying ? 25 : 0), anchor: .top)
                .position(x: size * 0.85, y: size * 0.35)
        }
    }
}
