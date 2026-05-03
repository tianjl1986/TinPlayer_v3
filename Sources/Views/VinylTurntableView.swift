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
            RoundedRectangle(cornerRadius: 24)
                .fill(DesignTokens.surfaceMain)
                .frame(width: baseSize, height: baseSize)
                .skeuoRaised(cornerRadius: 24)
            
            Image("turntable_base_light")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: baseSize, height: baseSize)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            // 2. Rotating Platter & Record
            ZStack {
                // Platter
                Image("platter_light")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: platterSize, height: platterSize)
                
                // Vinyl Record
                ZStack {
                    Image("vinyl_record_light")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: recordSize, height: recordSize)
                    
                    // Album Cover (Label)
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
                        }
                    } else {
                        Circle()
                            .fill(DesignTokens.surfaceLight)
                            .frame(width: labelSize, height: labelSize)
                    }
                    
                    // Center Spindle Piece
                    Image("spindle_light")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                }
                .rotationEffect(.degrees(rotation))
            }
            
            // 3. Tonearm Assembly
            ZStack {
                Image("tonearm_light")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 260)
                    .rotationEffect(.degrees(player.isPlaying ? -22 : -45), anchor: .init(x: 0.82, y: 0.18))
                    .offset(x: 110, y: -70)
            }
        }
        .frame(width: baseSize, height: baseSize)
        .onAppear {
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
