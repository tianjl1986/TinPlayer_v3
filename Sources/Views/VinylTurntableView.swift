import SwiftUI

struct VinylTurntableView: View {
    @StateObject private var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    
    // 🚀 Figma 1:1 物理尺寸与坐标 (基于 390x844 标准稿)
    private let screenWidth = UIScreen.main.bounds.width
    private let baseSize: CGFloat = 342
    private let platterSize: CGFloat = 310
    private let recordSize: CGFloat = 290
    @State private var tonearmRotation: Double = -135 // Initial rotation from audit
    
    var body: some View {
        ZStack {
            // Turntable Base - 9880:14740
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
                    
                    // Grooves (Simulated with Gradient)
                    Circle()
                        .fill(AngularGradient(stops: [
                            .init(color: Color(hexString: "#1a1a1a"), location: 0),
                            .init(color: Color(hexString: "#4d4d4d"), location: 0.25),
                            .init(color: Color(hexString: "#1a1a1a"), location: 0.5),
                            .init(color: Color(hexString: "#4d4d4d"), location: 0.75),
                            .init(color: Color(hexString: "#1a1a1a"), location: 1)
                        ], center: .center))
                        .frame(width: 290, height: 290)
                    
                    // Physical Grooves
                    ForEach(0..<10) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            .frame(width: CGFloat(280 - (i * 25)), height: CGFloat(280 - (i * 25)))
                    }
                    
                    // Center Label (Cover)
                    if let track = player.currentTrack {
                        AsyncImage(url: URL(string: track.coverUrl)) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                    }
                }
                .rotationEffect(.degrees(rotation))
                
                // Spindle - 9889:14767
                Circle()
                    .fill(AngularGradient(colors: [Color.gray, Color.white, Color.gray], center: .center))
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)
            }
            
            // Tonearm Base - 10491:8406
            Image("arm_base_light")
                .resizable()
                .frame(width: 80, height: 80)
                .offset(x: 130, y: -130)
            
            // Tonearm - 10491:8411
            Image("tonearm_light")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180)
                .rotationEffect(.degrees(player.isPlaying ? 25 : 0), anchor: .topTrailing)
                .offset(x: 85, y: -100)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: player.isPlaying)
        }
        .onAppear {
            if player.isPlaying { startRotation() }
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
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            rotation += 360
        }
    }
    
    private func stopRotation() {
        // Animation naturally stops if we reset or use a more controlled approach
    }
}
