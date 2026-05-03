import SwiftUI

struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @Binding var showLyrics: Bool
    @State private var rotation: Double = 0
    @State private var tonearmRotation: Double = 0 // 0: reset, 25: playing
    
    private let baseSize: CGFloat = 340
    private let vinylSize: CGFloat = 260
    
    var body: some View {
        ZStack {
            // 1. Bottom Base (Sunken Effect)
            RoundedRectangle(cornerRadius: 48)
                .fill(DesignTokens.surfaceSecondary)
                .frame(width: baseSize, height: baseSize)
                .skeuoSunken(cornerRadius: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: 48)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        .blur(radius: 1)
                        .offset(x: -1, y: -1)
                        .mask(RoundedRectangle(cornerRadius: 48))
                )
            
            // 2. Spinning Vinyl
            ZStack {
                // Vinyl grooves (Subtle circles)
                Circle()
                    .fill(Color(hexString: "#121212"))
                    .frame(width: vinylSize, height: vinylSize)
                    .shadow(color: Color.black.opacity(0.4), radius: 15, x: 5, y: 10)
                
                // Fine grooves texture
                ForEach(0..<10) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.03), lineWidth: 1)
                        .frame(width: vinylSize - CGFloat(i * 15), height: vinylSize - CGFloat(i * 15))
                }
                
                // Album Art Center
                if let cover = player.currentTrack?.coverImage ?? player.playlist.first?.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 90, height: 90)
                }
            }
            .rotationEffect(.degrees(rotation))
            
            // 3. Tonearm Assembly (Pivot fixed at top-right)
            TonearmView(isMoving: player.isPlaying)
                .offset(x: 80, y: -110)
        }
        .onAppear {
            startRotation()
        }
        .onChange(of: player.isPlaying) { isPlaying in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                tonearmRotation = isPlaying ? 25 : 0
            }
        }
    }
    
    private func startRotation() {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            if player.isPlaying {
                rotation += 0.5
            }
        }
    }
}

// MARK: - 精确拟物唱臂组件
struct TonearmView: View {
    var isMoving: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            // The Arm itself
            VStack(spacing: 0) {
                // Pivot Base (Top round part)
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hexString: "#F0F0F0"), Color(hexString: "#BDBDBD")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 2, y: 2)
                    
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 30, height: 30)
                }
                
                // The Rod (Metal stick)
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hexString: "#E0E0E0"), Color(hexString: "#FFFFFF"), Color(hexString: "#CCCCCC")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 8, height: 180)
                    .offset(y: -10)
                
                // Headshell (The needle part)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hexString: "#333333"))
                    .frame(width: 24, height: 36)
                    .overlay(
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 2, height: 10)
                            .offset(y: 10)
                    )
                    .rotationEffect(.degrees(-15))
                    .offset(x: -5, y: -15)
            }
            .rotationEffect(.degrees(isMoving ? 22 : 0), anchor: .top)
            .animation(.spring(response: 1.0, dampingFraction: 0.8), value: isMoving)
        }
    }
}
