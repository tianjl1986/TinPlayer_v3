import SwiftUI

// MARK: - 颜色系统（严格按Figma设计稿）
struct AppColors {
    // 主背景 #F2F2F2（Figma: WF/Fill-Light）
    static let background = Color(hex: "#F2F2F2")
    // 主文字 #000000
    static let textPrimary = Color(hex: "#000000")
    // 次要文字 #808080
    static let textSecondary = Color(hex: "#808080")
    // 神经拟态高光
    static let shadowLight = Color.white
    // 神经拟态阴影
    static let shadowDark = Color(hex: "#C8C8C8")
    // 唱片黑色
    static let vinylBlack = Color(hex: "#1A1A1A")
    // 间隔线
    static let separator = Color(hex: "#D0D0D0")
}

// MARK: - 颜色扩展
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 200, 200, 200)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - 神经拟态：凸起效果
struct SkeuoRaised: ViewModifier {
    var cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppColors.background)
                    .shadow(color: AppColors.shadowLight, radius: 6, x: -3, y: -3)
                    .shadow(color: AppColors.shadowDark, radius: 6, x: 3, y: 3)
            )
    }
}

// MARK: - 神经拟态：凹陷效果
struct SkeuoSunken: ViewModifier {
    var cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(AppColors.background)
                    // 内阴影：左上深
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(AppColors.shadowDark.opacity(0.5), lineWidth: 1)
                        .blur(radius: 2)
                        .offset(x: 1, y: 1)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(.black))
                    // 内阴影：右下亮
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(AppColors.shadowLight, lineWidth: 1)
                        .blur(radius: 2)
                        .offset(x: -1, y: -1)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(.black))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - View 扩展
extension View {
    func skeuoRaised(cornerRadius: CGFloat = 12) -> some View {
        modifier(SkeuoRaised(cornerRadius: cornerRadius))
    }
    func skeuoSunken(cornerRadius: CGFloat = 12) -> some View {
        modifier(SkeuoSunken(cornerRadius: cornerRadius))
    }
}

// MARK: - 时间格式化
func formatDuration(_ time: TimeInterval) -> String {
    guard time.isFinite && !time.isNaN && time >= 0 else { return "00:00" }
    let mins = Int(time) / 60
    let secs = Int(time) % 60
    return String(format: "%02d:%02d", mins, secs)
}
