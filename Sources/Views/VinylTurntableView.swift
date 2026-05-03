import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var theme = ThemeManager.shared
    @Binding var showLyrics: Bool
    @State private var rotation: Double = 0
    
    private let baseSize: CGFloat = 400 // Increased size
    
    var body: some View {
        ZStack {
            // 1. Bottom Base (Image Asset)
            Image(theme.isDark ? "turntable_base_dark" : "turntable_base_light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: baseSize, height: baseSize)
            
            // 1.5 Platter (Theme-aware and no shadow)
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: theme.isDark ? 
                            [Color(white: 0.1), Color(white: 0.2), Color(white: 0.05)] : 
                            [Color(white: 0.85), Color(white: 0.95), Color(white: 0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 300, height: 300)
            
            // 2. Spinning Vinyl (Image Asset)
            ZStack {
                Image(theme.isDark ? "vinyl_record_dark" : "vinyl_record_light")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280, height: 280)
                
                // Album Art Center
                Group {
                    if let cover = player.currentAlbum?.coverImage {
                        Image(uiImage: cover)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 95, height: 95)
                            .clipShape(Circle())
                    }
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 3. Tonearm Assembly (Pivot fixed at top-right 45-degree diagonal)
            TonearmView(isMoving: player.isPlaying)
                .offset(x: 150, y: -150) // Moved pivot to 45-degree diagonal
        }
        .onReceive(Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()) { _ in
            if player.isPlaying {
                rotation += 0.5
            }
        }
    }
}

struct TonearmView: View {
    var isMoving: Bool
    @ObservedObject var theme = ThemeManager.shared
    
    var body: some View {
        // The Tonearm is a single slice image
        Image(theme.isDark ? "tonearm_dark" : "tonearm_light")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 260) // Slightly larger
            .rotationEffect(.degrees(isMoving ? 8 : -2), anchor: .top) // More vertical angle
            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isMoving)
    }
}
