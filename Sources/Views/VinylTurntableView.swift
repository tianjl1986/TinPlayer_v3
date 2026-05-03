import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var theme = ThemeManager.shared
    @Binding var showLyrics: Bool
    @State private var rotation: Double = 0
    
    private let baseSize: CGFloat = 340
    
    var body: some View {
        ZStack {
            // 1. Bottom Base (Image Asset)
            Image(theme.isDark ? "turntable_base_dark" : "turntable_base_light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: baseSize, height: baseSize)
            
            // 2. Spinning Vinyl (Image Asset)
            ZStack {
                Image(theme.isDark ? "vinyl_record_dark" : "vinyl_record_light")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280, height: 280)
                
                // Album Art Center
                if let cover = player.currentTrack?.coverImage ?? player.playlist.first?.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 95, height: 95)
                        .clipShape(Circle())
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 3. Tonearm Assembly (Pivot fixed at top-right, using slice)
            TonearmView(isMoving: player.isPlaying)
                .offset(x: 75, y: -95)
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
            .frame(width: 120, height: 280) // Adjust based on slice dimensions
            .rotationEffect(.degrees(isMoving ? 25 : 0), anchor: .top)
            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: isMoving)
    }
}
