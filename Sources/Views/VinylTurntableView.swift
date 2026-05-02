import SwiftUI

struct VinylTurntableView: View {
    @StateObject private var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    
    // 1:1 设计参数
    private let baseSize: CGFloat = UIScreen.main.bounds.width - 48
    private let platterScale: CGFloat = 0.88
    private let tonearmOffset: CGFloat = 40
    
    // 封面图处理逻辑 (修复编译错误)
    private var albumCover: UIImage? {
        guard let track = player.currentTrack else { return nil }
        // 从库中查找该轨道所属的专辑封面
        return MusicLibraryService.shared.albums.first { album in
            album.tracks.contains { $0.id == track.id }
        }?.coverImage
    }
    
    var body: some View {
        ZStack {
            // 1. 底座 (物理切片)
            Image("turntable_base")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: baseSize)
                .skeuoRaised(cornerRadius: 24)
            
            // 2. 转盘 (旋转部分)
            ZStack {
                Image("platter")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: baseSize * platterScale)
                
                // 3. 唱片中心封面 (Album Art)
                if let cover = albumCover {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: baseSize * 0.3, height: baseSize * 0.3)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black.opacity(0.2), lineWidth: 1))
                } else {
                    // 默认黑色圆心
                    Circle()
                        .fill(Color.black.opacity(0.8))
                        .frame(width: baseSize * 0.3, height: baseSize * 0.3)
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 4. 唱臂 (物理切片)
            Image("tonearm")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: baseSize * 0.7)
                .rotationEffect(.degrees(player.isPlaying ? 25 : 0), anchor: .topTrailing)
                .offset(x: tonearmOffset, y: -tonearmOffset)
        }
        .onAppear {
            startRotation()
        }
        .onChange(of: player.isPlaying) { isPlaying in
            if isPlaying { startRotation() }
        }
    }
    
    private func startRotation() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            if player.isPlaying {
                rotation += 360
            }
        }
    }
}
