import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 🚀 1. 唱机机身底座 (Pure Code Restoration - Figma 9880:14740)
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.currentTheme == .light ? Color(hex: "#F5F5F5") : Color(hex: "#1A1A1A"))
                .frame(width: 320, height: 320)
                .skeuoRaised(radius: 12, offset: 6)
                .overlay(
                    // 底座金属纹理
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(themeManager.currentTheme == .light ? 0.5 : 0.05), lineWidth: 1)
                )
            
            // 🚀 2. 唱片托盘 (Platter)
            Circle()
                .fill(
                    LinearGradient(colors: [
                        Color(hex: "#333333"), 
                        Color(hex: "#111111"), 
                        Color(hex: "#222222")
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 290, height: 290)
                .skeuoRaised(radius: 4, offset: 2)
            
            // 🚀 3. 黑胶唱片主体 (Restored with Rings)
            ZStack {
                // Record Base
                Circle()
                    .fill(Color(hex: "#050505"))
                    .frame(width: 280, height: 280)
                
                // Groove Rings
                ForEach(0..<15) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.03), lineWidth: 1)
                        .frame(width: CGFloat(140 + i * 8), height: CGFloat(140 + i * 8))
                }
                
                // 专辑封面标签 (Label)
                ZStack {
                    if let track = player.currentTrack,
                       let album = MusicLibraryService.shared.albums.first(where: { $0.tracks.contains(where: { $0.id == track.id }) }),
                       let image = album.coverImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black.opacity(0.2), lineWidth: 4))
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 110, height: 110)
                    }
                    
                    // 中心孔
                    Circle()
                        .fill(Color(hex: "#111111"))
                        .frame(width: 8, height: 8)
                }
            }
            .rotationEffect(.degrees(rotation))
            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            
            // 🚀 4. 拟物化唱臂 (Pure Code Restoration - Figma 10411:1952)
            TonearmView(isPlaying: player.isPlaying)
                .offset(x: 100, y: -70)
        }
        .frame(width: 390, height: 390)
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
        ZStack(alignment: .topTrailing) {
            // 唱臂主体 (Arm)
            VStack(spacing: 0) {
                // Base Pivot
                Circle()
                    .fill(
                        LinearGradient(colors: [Color(hex: "#999999"), Color(hex: "#666666")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 50, height: 50)
                    .skeuoRaised(radius: 6, offset: 3)
                
                // The Pipe
                Capsule()
                    .fill(
                        LinearGradient(colors: [Color(hex: "#CCCCCC"), Color(hex: "#888888"), Color(hex: "#AAAAAA")], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 12, height: 180)
                    .offset(y: -10)
                
                // Headshell (The part with the stylus)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "#222222"))
                    .frame(width: 24, height: 40)
                    .offset(y: -20)
                    .overlay(
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 2, height: 10)
                            .offset(y: 10),
                        alignment: .bottom
                    )
            }
            .rotationEffect(.degrees(isPlaying ? 28 : 0), anchor: .top)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isPlaying)
        }
        .shadow(color: .black.opacity(0.3), radius: 8, x: 10, y: 15)
    }
}
