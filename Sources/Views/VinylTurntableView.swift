import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @State private var rotation: Double = 0
    
    // Geometry constants based on assets - Adjusted for iPhone 14 Pro
    private let baseSize: CGFloat = 335
    private let platterSize: CGFloat = 280
    private let recordSize: CGFloat = 260
    private let labelSize: CGFloat = 80
    
    // Timer for smooth rotation
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 1. Turntable Base
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(DesignTokens.surfaceMain)
                    .frame(width: baseSize, height: baseSize)
                    .skeuoRaised(cornerRadius: 24)
                
                Image("turntable_base_light")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: baseSize, height: baseSize)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            
            // 2. Rotating Platter & Record
            ZStack {
                // Platter
                Image("platter_light")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: platterSize, height: platterSize)
                    .rotationEffect(.degrees(rotation))
                
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
                        .frame(width: 24, height: 24)
                }
                .rotationEffect(.degrees(rotation))
            }
            
            // 3. Tonearm Assembly - High Precision Alignment
            ZStack {
                Image("tonearm_light")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140) // Reduced size
                    .rotationEffect(.degrees(player.isPlaying ? -8 : -35), anchor: .init(x: 0.85, y: 0.15))
                    .offset(x: 95, y: -65)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: player.isPlaying)
            }
        }
        .frame(width: baseSize, height: baseSize)
        .onReceive(timer) { _ in
            if player.isPlaying {
                rotation += 1.2 // Smoother rotation
            }
        }
    }
}

