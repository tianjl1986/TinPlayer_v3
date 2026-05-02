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
// Figma中：Tonearm Assembly 位于右上角。Pivot中心约在 (size*0.82, size*0.25)
struct TonearmView: View {
    let isPlaying: Bool
    let size: CGFloat

    // 播放时臂转入唱片（约从0度转到25度），停止时退出到0度
    private var armAngle: Double { isPlaying ? 25.0 : 0.0 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 唱针枢轴底座（Pivot）
            ZStack {
                // 底座外圈阴影
                Circle()
                    .fill(AppColors.background)
                    .frame(width: size * 0.18, height: size * 0.18)
                    .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                    .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)

                // 金属圆环
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#CCCCCC"), Color(hex: "#999999")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: size * 0.04
                    )
                    .frame(width: size * 0.12, height: size * 0.12)

                // 中心圆点
                Circle()
                    .fill(Color(hex: "#EEEEEE"))
                    .frame(width: size * 0.05, height: size * 0.05)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0.5, y: 0.5)
            }
            .position(x: size * 0.82, y: size * 0.20) // Figma 比例位置

            // 唱针臂（Arm + Headshell）
            ZStack(alignment: .top) {
                // 1. 弯曲的唱针杆
                TonearmCurveShape()
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: "#DDDDDD"), Color(hex: "#999999"), Color(hex: "#BBBBBB")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round)
                    )
                    .frame(width: size * 0.15, height: size * 0.55)
                    .offset(y: size * 0.03) // 从枢轴中心开始偏移一点

                // 2. 唱头（Headshell）
                VStack(spacing: 0) {
                    // 唱头外壳
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#444444"), Color(hex: "#222222")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size * 0.07, height: size * 0.12)
                        .overlay(
                            // 细节装饰线
                            VStack(spacing: 4) {
                                Capsule().fill(Color.white.opacity(0.2)).frame(width: 12, height: 2)
                                Capsule().fill(Color.white.opacity(0.2)).frame(width: 12, height: 2)
                            }
                        )

                    // 唱针头
                    Capsule()
                        .fill(Color(hex: "#888888"))
                        .frame(width: 2, height: size * 0.04)
                        .offset(y: -2)
                }
                .offset(x: -size * 0.08, y: size * 0.52) // 移动到弯杆末端
            }
            .rotationEffect(.degrees(armAngle), anchor: .top)
            .animation(.spring(response: 1.0, dampingFraction: 0.7), value: isPlaying)
            .position(x: size * 0.82, y: size * 0.20) // 绕枢轴旋转
        }
    }
}

// 模拟 Figma 中的 S 型或弯曲唱针杆
struct TonearmCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: 0))
        // 稍微向右弯曲再向左回正
        path.addCurve(
            to: CGPoint(x: rect.midX - rect.width * 0.5, y: rect.height),
            control1: CGPoint(x: rect.midX + rect.width * 0.2, y: rect.height * 0.3),
            control2: CGPoint(x: rect.midX, y: rect.height * 0.7)
        )
        return path
    }
}
