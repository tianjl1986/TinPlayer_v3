import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @ObservedObject var theme = ThemeManager.shared
    @State private var rotation: Double = 0
    @Binding var showLyrics: Bool
    
    // Geometry constants based on assets - Adjusted for 1:1 fidelity
    private let baseSize: CGFloat = 335
    private let platterSize: CGFloat = 310
    private let recordSize: CGFloat = 290 // 🚀 Restored to 290 as requested
    private let labelSize: CGFloat = 135 // 🚀 Large artwork label
    private let tonearmWidth: CGFloat = 100
    private let tonearmPivotOffset: CGFloat = 20
    
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
                
                Image(theme.isDark ? "turntable_base_dark" : "turntable_base_light")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: baseSize, height: baseSize)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            
            // 2. Rotating Platter & Record
            Button(action: { showLyrics = true }) {
                ZStack {
                    // Platter
                    Image(theme.isDark ? "platter_dark" : "platter_light")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: platterSize, height: platterSize)
                        .rotationEffect(.degrees(rotation))
                    
                    // Vinyl Record
                    ZStack {
                        Image(theme.isDark ? "vinyl_record_dark" : "vinyl_record_light")
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
                        }
                        
                        // Center Spindle Piece
                        Image(theme.isDark ? "spindle_dark" : "spindle_light")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    .rotationEffect(.degrees(rotation))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
                // 3. Tonearm Assembly (Precision Coaxial Alignment)
                ZStack {
                    // Base: Using a drawn Circle for 100% geometric center accuracy
                    Circle()
                        .fill(DesignTokens.surfaceMain)
                        .frame(width: 44, height: 44)
                        .skeuoRaised(cornerRadius: 22)
                    
                    Circle()
                        .fill(LinearGradient(colors: [.white.opacity(0.5), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 40, height: 40)
                    
                    // Tonearm Image (Precision Pivot)
                    Image(theme.isDark ? "tonearm_dark" : "tonearm_light")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: tonearmWidth)
                        // 🚀 核心数学计算：
                        // 假设图片高宽比为 2.5 (100x250)，中心点在 125。
                        // 锚点 0.215 在 53.75。位移补偿 = 125 - 53.75 = 71.25。
                        // 经过多轮验证，offset 86pt 是最契合该资产圆心位置的参数。
                        .offset(y: 86) 
                        .rotationEffect(.degrees(player.isPlaying ? -5 : -35), anchor: .init(x: 0.5, y: 0.215))
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: player.isPlaying)
                }
                .offset(x: 130, y: -130)
        }
        .frame(width: baseSize, height: baseSize)
        .onReceive(timer) { _ in
            if player.isPlaying {
                rotation += 1.5 // Increased speed slightly for better visual
            }
        }
    }
}

