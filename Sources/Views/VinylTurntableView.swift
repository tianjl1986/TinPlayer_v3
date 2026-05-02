import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // 🚀 1. 唱机机身底座 (Pure Code Restoration - Figma 9880:14740)
            RoundedRectangle(cornerRadius: 32) // 🚀 Figma 9880:14740
                .fill(themeManager.currentTheme == .light ? Color(hex: "#E5E5E5") : Color(hex: "#1A1A1A"))
                .frame(width: 342, height: 400) 
                .skeuoRaised(radius: 8, offset: 4)
                .overlay(
                    // 底座金属纹理
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(themeManager.currentTheme == .light ? 0.5 : 0.05), lineWidth: 1)
                )
            
            // 🚀 2. 唱片托盘 (Platter)
            Circle()
                .fill(themeManager.currentTheme == .light ? Color(hex: "#E5E5E5") : Color(hex: "#111111"))
                .frame(width: 310, height: 310) // 🚀 Figma 9880:14763
                .skeuoSunken(radius: 8, offset: 4)
            
            // 🚀 3. 黑胶唱片主体 (Restored with Rings)
            ZStack {
                // Record Base
                Circle()
                    .fill(Color(hex: "#1A1A1A"))
                    .frame(width: 290, height: 290) // 🚀 Figma 9880:14759
                
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
                            .frame(width: 135, height: 135) // 🚀 Figma 9927:15066
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 110, height: 110)
                    }
                    
                    // 中心孔
                    Circle()
                        .fill(Color(hex: "#111111"))
                        .frame(width: 14, height: 14) // 🚀 Figma 9889:14767
                }
            }
            .rotationEffect(.degrees(rotation))
            .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            
            // 🚀 4. 拟物化唱臂 (Pure Code Restoration - Figma 9893:14773)
            TonearmView(isPlaying: player.isPlaying)
                .offset(x: 100, y: -70) // 🚀 Refined positioning on 342x400 base
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
            // Pivot Base (Mechanical Foundation)
            Circle()
                .fill(
                    AngularGradient(colors: [
                        Color(hex: "#999999"), 
                        Color(hex: "#FFFFFF"), 
                        Color(hex: "#666666"), 
                        Color(hex: "#FFFFFF"), 
                        Color(hex: "#999999")
                    ], center: .center)
                )
                .frame(width: 60, height: 60)
                .skeuoRaised(radius: 8, offset: 4)
            
            // The Arm Assembly
            VStack(spacing: 0) {
                // Counterweight (Back Part)
                RoundedRectangle(cornerRadius: 4)
                    .fill(themeManager.currentTheme == .light ? Color(hex: "#333333") : Color(hex: "#111111"))
                    .frame(width: 20, height: 30)
                
                // The Pipe (Metal Rod)
                Capsule()
                    .fill(
                        LinearGradient(colors: [Color(hex: "#CCCCCC"), Color(hex: "#FFFFFF"), Color(hex: "#888888")], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 8, height: 180)
                    .offset(y: -5)
                
                // Headshell (The part with the stylus)
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#222222"))
                        .frame(width: 24, height: 44)
                    
                    // Stylus
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 2, height: 12)
                        .offset(y: 6)
                }
                .offset(y: -15)
                .rotationEffect(.degrees(-5))
            }
            .offset(y: 30) // Pivot at 30pt down from top of pivot base
            .rotationEffect(.degrees(isPlaying ? 24 : 0), anchor: .top)
            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isPlaying)
        }
        .offset(x: 20, y: 0)
    }

}
