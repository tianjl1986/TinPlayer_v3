import SwiftUI

struct VinylTurntableView: View {
    @StateObject private var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 1. Turntable Base Asset
            Image("turntable_base")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            // 2. Rotating Platter
            ZStack {
                Image("platter")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                // Vinyl Record Artwork
                // Simplified access to fix compiler error
                Circle()
                    .fill(Color.black.opacity(0.8))
                    .frame(width: 220, height: 220)
                
                Image("spindle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
            }
            .rotationEffect(.degrees(rotation))
            .frame(width: 310, height: 310)
            
            // 3. Tonearm Asset
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
                rotation += 2.5
            }
        }
    }
}
