import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 🚀 1. 唱机机身底座 (Asset Based)
            Image(themeManager.currentTheme == .light ? "turntable_base_light" : "turntable_base_dark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 380, height: 380)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // 🚀 2. 黑胶唱片主体 (Asset Based)
            ZStack {
                Image(themeManager.currentTheme == .light ? "vinyl_record_light" : "vinyl_record_dark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 320)
                
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
                    
                    // 中心主轴盖
                    Circle()
                        .fill(RadialGradient(colors: [Color.white.opacity(0.5), Color.clear], center: .center, startRadius: 0, endRadius: 8))
                        .frame(width: 16, height: 16)
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 🚀 3. 拟物化唱臂 (Asset Based)
            TonearmView(isPlaying: player.isPlaying)
                .offset(x: 100, y: -80) // 🚀 调整唱臂位置对齐机身资源
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
    @ObservedObject var themeManager = ThemeManager.shared
    
    var body: some View {
        Image(themeManager.currentTheme == .light ? "tonearm_light" : "tonearm_dark")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 120) // 🚀 根据资源比例调整
            .rotationEffect(.degrees(isPlaying ? 25 : 0), anchor: .topTrailing)
            .shadow(color: .black.opacity(0.4), radius: 10, x: 5, y: 10)
    }
}
