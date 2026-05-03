import SwiftUI

struct VinylTurntableView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @State private var rotation: Double = 0
    
    // Geometry constants based on assets
    private let baseSize: CGFloat = 360
    private let platterSize: CGFloat = 300
    private let recordSize: CGFloat = 280
    private let labelSize: CGFloat = 90
    
    var body: some View {
        ZStack {
            // 1. Turntable Base (Static Background)
            Image("turntable_base_light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: baseSize, height: baseSize)
            
            // 2. Rotating Platter & Record
            ZStack {
                // Platter
                Image("platter_light")
                    .resizable()
                    .frame(width: platterSize, height: platterSize)
                
                // Vinyl Record
                Image("vinyl_record_light")
                    .resizable()
                    .frame(width: recordSize, height: recordSize)
                
                // Album Cover (Label)
                ZStack {
                    if let track = player.currentTrack {
                        let album = libraryService.albums.first(where: { $0.tracks.contains(track) })
                        if let cover = album?.coverImage {
                            Image(uiImage: cover)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: labelSize, height: labelSize)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(DesignTokens.surfaceLight)
                                .frame(width: labelSize, height: labelSize)
                            Image(systemName: "music.note")
                                .font(.system(size: 30))
                                .foregroundColor(DesignTokens.textSecondary.opacity(0.2))
                        }
                    } else {
                        Circle()
                            .fill(DesignTokens.surfaceLight)
                            .frame(width: labelSize, height: labelSize)
                    }
                    
                    // Center Spindle Piece
                    Image("spindle_light")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 3. Tonearm (Placed over the record)
            Image("tonearm_light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180)
                .rotationEffect(.degrees(player.isPlaying ? -25 : -45), anchor: .topTrailing)
                .offset(x: 100, y: -60)
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: player.isPlaying)
        }
        .onAppear {
            if player.isPlaying {
                startRotation()
            }
        }
        .onChange(of: player.isPlaying) { isPlaying in
            if isPlaying {
                startRotation()
            }
        }
    }
    
    private func startRotation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotation += 360
        }
    }
}
