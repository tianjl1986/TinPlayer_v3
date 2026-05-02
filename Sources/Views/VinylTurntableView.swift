import SwiftUI

struct VinylTurntableView: View {
    @StateObject private var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 1. Turntable Base Asset (The foundation)
            Image("turntable_base")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            // 2. Rotating Platter & Record Group
            ZStack {
                // Platter Asset
                Image("platter")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                // Vinyl Record (The actual artwork)
                if let artwork = player.currentTrack?.artwork {
                    Image(uiImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 220, height: 220) // Correct relative scale to platter
                        .clipShape(Circle())
                }
                
                // Spindle Asset (Center pin)
                Image("spindle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
            }
            .rotationEffect(.degrees(rotation))
            .frame(width: 310, height: 310) // Standardized size to fit base
            
            // 3. Tonearm Asset (Pivot at Top-Right)
            // Positioned exactly on the base's tonearm base area
            Image("tonearm")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .rotationEffect(.degrees(player.isPlaying ? 28 : 2), anchor: .topTrailing)
                .offset(x: 75, y: -65)
                .shadow(color: Color.black.opacity(0.4), radius: 8, x: 5, y: 8)
        }
        .onReceive(timer) { _ in
            if player.isPlaying {
                rotation += 2.5 // Smooth 33rpm rotation feel
            }
        }
    }
}
