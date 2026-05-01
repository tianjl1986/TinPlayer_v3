import SwiftUI

// MARK: - 黑胶转盘视图（1:1 还原 Figma 9880:14735）
// 设计尺寸：Turntable Base 342×400，Platter 310×310，Vinyl 290×290，Label 135×135
struct VinylTurntableView: View {
    @ObservedObject var player = MusicPlayer.shared
    @State private var rotation: Double = 0
    let timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let baseSize = size           // 转盘底座
            let platSize = size * 0.905  // Platter: 310/342
            let vinylSize = size * 0.848 // Vinyl: 290/342
            let labelSize = size * 0.395 // Label: 135/342

            ZStack {
                // 1. 转盘底座（Raised）
                RoundedRectangle(cornerRadius: size * 0.093) // 32/342
                    .fill(AppColors.background)
                    .frame(width: baseSize, height: baseSize)
                    .shadow(color: AppColors.shadowLight, radius: 8, x: -5, y: -5)
                    .shadow(color: AppColors.shadowDark, radius: 10, x: 6, y: 6)

                // 2. 转盘凹槽（Platter - Sunken圆形）
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#D8D8D8"),
                                Color(hex: "#E8E8E8"),
                                Color(hex: "#F0F0F0")
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: platSize / 2
                        )
                    )
                    .frame(width: platSize, height: platSize)
                    .shadow(color: AppColors.shadowDark.opacity(0.8), radius: 6, x: 4, y: 4)
                    .shadow(color: AppColors.shadowLight, radius: 4, x: -3, y: -3)

                // 3. 黑胶唱片（旋转组）
                ZStack {
                    // 唱片主体
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#2A2A2A"),
                                    Color(hex: "#111111"),
                                    Color(hex: "#1A1A1A")
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: vinylSize / 2
                            )
                        )
                        .frame(width: vinylSize, height: vinylSize)

                    // 唱片纹路（Grooves - 6道）
                    ForEach(0..<6) { i in
                        let ringSize = vinylSize * (0.97 - Double(i) * 0.05)
                        Circle()
                            .stroke(
                                Color.white.opacity(0.04 + Double(i) * 0.01),
                                lineWidth: 0.8
                            )
                            .frame(width: ringSize, height: ringSize)
                    }
                    // 更多细密纹路
                    ForEach(0..<8) { i in
                        let ringSize = vinylSize * (0.67 - Double(i) * 0.03)
                        if ringSize > labelSize {
                            Circle()
                                .stroke(Color.white.opacity(0.03), lineWidth: 0.5)
                                .frame(width: ringSize, height: ringSize)
                        }
                    }

                    // 专辑封面（Center Label - 方形）
                    ZStack {
                        // 白色底
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F0F0F0"))
                            .frame(width: labelSize, height: labelSize)

                        // 封面图
                        if let artwork = player.currentTrack?.artwork {
                            Image(uiImage: artwork)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: labelSize, height: labelSize)
                                .clipped()
                        } else {
                            // 占位符
                            VStack(spacing: 4) {
                                Image(systemName: "music.note")
                                    .font(.system(size: labelSize * 0.3))
                                    .foregroundColor(Color(hex: "#999999"))
                            }
                            .frame(width: labelSize, height: labelSize)
                        }

                        // 中心主轴（Spindle）
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#AAAAAA"),
                                        Color(hex: "#555555")
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 7
                                )
                            )
                            .frame(width: 14, height: 14)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 1)
                    }
                }
                .frame(width: vinylSize, height: vinylSize)
                .rotationEffect(.degrees(rotation))

                // 4. 唱针（Tonearm - 右上角）
                TonearmView(isPlaying: player.isPlaying, size: size)
            }
            .frame(width: baseSize, height: baseSize)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .onReceive(timer) { _ in
            if player.isPlaying {
                withAnimation(.linear(duration: 0.04)) {
                    rotation += 1.5
                    if rotation >= 360 { rotation = 0 }
                }
            }
        }
    }
}

// MARK: - 唱针（Tonearm）
// Figma中：Tonearm Assembly 位于 右上角，相对底座偏移约 x+160, y-160 区域
struct TonearmView: View {
    let isPlaying: Bool
    let size: CGFloat

    // 播放时臂转入唱片，停止时退出
    private var armAngle: Double { isPlaying ? 22.0 : 0.0 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 唱针臂整体容器
            VStack { Spacer() }
                .frame(width: size * 0.47, height: size * 0.47)
        }
        .overlay(
            GeometryReader { _ in
                ZStack(alignment: .topTrailing) {
                    // 唱针主杆（细长杆）
                    TonearmShape()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#E0E0E0"),
                                    Color(hex: "#B0B0B0"),
                                    Color(hex: "#D0D0D0")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 8, height: size * 0.5)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                        .rotationEffect(.degrees(armAngle), anchor: .top)
                        .animation(.spring(response: 0.8, dampingFraction: 0.65), value: isPlaying)

                    // 唱头（Headshell - 末端）
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "#333333"))
                        .frame(width: 18, height: 28)
                        .overlay(
                            // 唱针尖（细线）
                            Rectangle()
                                .fill(Color(hex: "#888888"))
                                .frame(width: 1.5, height: 10)
                                .offset(y: 18)
                        )
                        .offset(y: size * 0.48)
                        .rotationEffect(.degrees(armAngle), anchor: .top)
                        .animation(.spring(response: 0.8, dampingFraction: 0.65), value: isPlaying)

                    // 枢轴底座（Pivot）- 圆形金属旋钮
                    ZStack {
                        Circle()
                            .fill(AppColors.background)
                            .frame(width: 44, height: 44)
                            .shadow(color: AppColors.shadowLight, radius: 5, x: -3, y: -3)
                            .shadow(color: AppColors.shadowDark, radius: 5, x: 3, y: 3)

                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "#E0E0E0"),
                                        Color(hex: "#909090")
                                    ]),
                                    center: .init(x: 0.35, y: 0.35),
                                    startRadius: 2,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 30, height: 30)

                        Circle()
                            .fill(Color(hex: "#555"))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        )
        .frame(width: size * 0.47, height: size * 0.47)
        .offset(x: size * 0.26, y: -size * 0.26)
    }
}

// 唱针杆形状
struct TonearmShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // 略微弯曲的杆
        p.move(to: CGPoint(x: rect.midX - 4, y: 0))
        p.addLine(to: CGPoint(x: rect.midX + 4, y: 0))
        p.addLine(to: CGPoint(x: rect.midX + 3, y: rect.height))
        p.addLine(to: CGPoint(x: rect.midX - 3, y: rect.height))
        p.closeSubpath()
        return p
    }
}
