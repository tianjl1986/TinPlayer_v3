import SwiftUI

struct VinylTurntableView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @State private var rotation: Double = 0
    
    // Geometry constants based on assets - Adjusted for iPhone 14 Pro (393 width)
    private let baseSize: CGFloat = 335 // Fits within 393 with 29 padding on each side
    private let platterSize: CGFloat = 280
    private let recordSize: CGFloat = 260
    private let labelSize: CGFloat = 80
    
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
                .animation(nil, value: rotation) // Prevent base from participating in animation
            
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
                        .frame(width: 24, height: 24)
                }
                .rotationEffect(.degrees(rotation))
            }
            .animation(nil, value: rotation) // Ensure only rotationEffect uses the animation
            
            // 3. Tonearm Assembly
            ZStack {
                Image("tonearm_light")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200) // Shrunk to fit better
                    .rotationEffect(.degrees(player.isPlaying ? -15 : -40), anchor: .init(x: 0.85, y: 0.15))
                    .offset(x: 90, y: -60)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: player.isPlaying)
            }
        }
        .frame(width: baseSize, height: baseSize)
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
        // Use animation only for the rotation state
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotation += 360
        }
    }
}
