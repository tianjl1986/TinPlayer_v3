import SwiftUI

struct VinylTurntableView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @State private var rotation: Double = 0
    @State private var isSpinning: Bool = false
    
    // Figma 1:1 几何参数
    private let baseSize: CGFloat = 340
    private let platterSize: CGFloat = 300
    private let recordSize: CGFloat = 280
    private let labelSize: CGFloat = 100
    
    var body: some View {
        ZStack {
            // 1. 底座 (Raised Base) - 9880:14740
            Circle()
                .fill(DesignTokens.surfaceMain)
                .frame(width: baseSize, height: baseSize)
                .skeuoRaised(cornerRadius: baseSize/2)
            
            // 2. 转盘 (Sunken Platter) - 10007:16492
            Circle()
                .fill(DesignTokens.surfaceMain)
                .frame(width: platterSize, height: platterSize)
                .skeuoSunken(cornerRadius: platterSize/2)
            
            // 3. 黑胶唱片 (The Record)
            ZStack {
                // 唱片主体 (Vinyl Texture)
                Circle()
                    .fill(Color.black)
                    .frame(width: recordSize, height: recordSize)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .padding(2)
                    )
                
                // 唱片纹理 (Grooves)
                ForEach(0..<10) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        .padding(CGFloat(i * 12))
                }
                
                // 4. 专辑封面 (Label)
                ZStack {
                    if let track = player.currentTrack {
                        // 寻找对应专辑封面
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
                                .font(.system(size: 40))
                                .foregroundColor(DesignTokens.textSecondary.opacity(0.2))
                        }
                    } else {
                        Circle()
                            .fill(DesignTokens.surfaceLight)
                            .frame(width: labelSize, height: labelSize)
                    }
                    
                    // 中心孔
                    Circle()
                        .fill(DesignTokens.surfaceMain)
                        .frame(width: 8, height: 8)
                        .skeuoSunken(cornerRadius: 4)
                }
            }
            .rotationEffect(.degrees(rotation))
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .onAppear {
            if player.isPlaying {
                startRotation()
            }
        }
        .onChange(of: player.isPlaying) { isPlaying in
            if isPlaying {
                startRotation()
            } else {
                stopRotation()
            }
        }
    }
    
    private func startRotation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            rotation += 360
        }
    }
    
    private func stopRotation() {
        // Stop animation logic
    }
}
