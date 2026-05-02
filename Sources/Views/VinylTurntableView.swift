import SwiftUI

struct VinylTurntableView: View {
    @StateObject private var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    
    // 🚀 Figma 1:1 物理尺寸与坐�?(基于 390x844 标准�?
    private let screenWidth = UIScreen.main.bounds.width
    private let baseSize: CGFloat = 342
    private let platterSize: CGFloat = 310
    private let recordSize: CGFloat = 290
    @State private var tonearmRotation: Double = -135 // Initial rotation from audit
    
    var body: some View {
        VStack(spacing: 32) {
            // 1. Top Bar - 9880:14736
            HStack {
                Text("<").font(.system(size: 20, weight: .bold))
                Spacer()
                Text("NOW PLAYING").font(.system(size: 14, weight: .black))
                Spacer()
                Text("...").font(.system(size: 20, weight: .bold))
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            // 2. Turntable Base - 9880:14740
            ZStack {
                // Base
                RoundedRectangle(cornerRadius: 32)
                    .fill(DesignTokens.surfaceMain)
                    .skeuoRaised(cornerRadius: 32)
                    .frame(width: 350, height: 350)
                
                // Platter (Sunken) - 9880:14763
                Circle()
                    .fill(DesignTokens.surfaceMain)
                    .skeuoSunken(cornerRadius: 155)
                    .frame(width: 310, height: 310)
                
                // Vinyl Record Group - 9970:15678
                ZStack {
                    Circle() // Record
                        .fill(Color.black)
                        .frame(width: 290, height: 290)
                    
                    // Grooves (Simulated)
                    ForEach(0..<10) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .frame(width: CGFloat(280 - (i * 20)), height: CGFloat(280 - (i * 20)))
                    }
                    
                    // Center Label (Cover)
                    if let track = player.currentTrack {
                        AsyncImage(url: URL(string: track.coverUrl)) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    }
                }
                .rotationEffect(.degrees(player.isPlaying ? 360 : 0))
                .animation(player.isPlaying ? Animation.linear(duration: 4).repeatForever(autoreverses: false) : .default, value: player.isPlaying)
                
                // Spindle - 9889:14767
                Circle()
                    .fill(AngularGradient(colors: [Color.gray, Color.white, Color.gray], center: .center))
                    .frame(width: 20, height: 20)
                    .shadow(radius: 2)
                
                // Tonearm Assembly - 9893:14773
                Image("tonearm_light")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .offset(x: 130, y: -130)
            
            // 唱臂主体 (旋转动画)
            Image("tonearm_arm_light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180)
                .rotationEffect(.degrees(player.isPlaying ? 28 : 0), anchor: .topTrailing)
                .offset(x: 85, y: -100)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: player.isPlaying)
        }
        .onAppear {
            if player.isPlaying { startRotation() }
        }
        .onChange(of: player.isPlaying) { isPlaying in
            if isPlaying { startRotation() }
        }
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
