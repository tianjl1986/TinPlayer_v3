import SwiftUI
import Combine

struct NowPlayingView: View {
    @State private var rotation: Double = 0
    @State private var isPlaying = false
    @State private var progress: Double = 0.35
    
    // 使用标准的 Combine 定时器
    let timer = Foundation.Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 背景
            Rectangle()
                .fill(Color(white: 0.95))
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 顶部
                HStack {
                    Image(systemName: "chevron.down")
                    Spacer()
                    Text("Now Playing")
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Image(systemName: "list.bullet")
                }
                .padding(.horizontal, 30)
                
                // 转盘
                VinylTurntableView(rotation: rotation, isPlaying: isPlaying)
                    .frame(maxHeight: 450)
                
                // 信息
                VStack(spacing: 8) {
                    Text("Random Access Memories")
                        .font(.system(size: 24, weight: .black))
                    Text("Daft Punk")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                
                // 进度
                VStack(spacing: 12) {
                    Slider(value: $progress)
                        .accentColor(.black)
                    HStack {
                        Text("1:24").font(.caption).monospacedDigit()
                        Spacer()
                        Text("-2:58").font(.caption).monospacedDigit()
                    }
                }
                .padding(.horizontal, 40)
                
                // 控制
                HStack(spacing: 50) {
                    Image(systemName: "backward.fill").font(.title)
                    Button {
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.black)
                    }
                    Image(systemName: "forward.fill").font(.title)
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .onReceive(timer) { _ in
            if isPlaying {
                rotation += 1.5
            }
        }
    }
}
