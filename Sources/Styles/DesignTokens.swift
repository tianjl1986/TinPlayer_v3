import SwiftUI

// MARK: - 主题模式
enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
}

// MARK: - 颜色系统（支持主题切换）
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("appTheme") var currentTheme: AppTheme = .light
    
    var background: Color {
        currentTheme == .light ? Color(hex: "#e5e5e5") : Color(hex: "#121212")
    }
    
    var textPrimary: Color {
        currentTheme == .light ? Color(hex: "#18181b") : Color(hex: "#fafafa")
    }
    
    var textSecondary: Color {
        currentTheme == .light ? Color(hex: "#71717a") : Color(hex: "#a1a1aa")
    }
    
    var shadowLight: Color {
        currentTheme == .light ? Color.white : Color(hex: "#1e1e1e")
    }
    
    var shadowDark: Color {
        currentTheme == .light ? Color(hex: "#b3b3b3") : Color(hex: "#000000")
    }
    
    var vinylBlack: Color {
        Color(hex: "#09090b")
    }
    
    var separator: Color {
        currentTheme == .light ? Color(hex: "#d4d4d8") : Color(hex: "#27272a")
    }
}

// 为了向下兼容，保留 AppColors 引用
struct AppColors {
    static var background: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "#121212")! : UIColor(hex: "#f4f4f5")!
        })
    }
    
    static var textPrimary: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : UIColor(hex: "#18181b")!
        })
    }
    
    static var textSecondary: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "#a1a1aa")! : UIColor(hex: "#71717a")!
        })
    }
    
    static var separator: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: "#27272a")! : UIColor(hex: "#e4e4e7")!
        })
    }
    
    static var shadowLight: Color { ThemeManager.shared.shadowLight }
    static var shadowDark: Color { ThemeManager.shared.shadowDark }
    static var vinylBlack: Color { ThemeManager.shared.vinylBlack }
}

// 🚀 自定义拟物化开关样式
struct SkeuoToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack {
                // 背景槽
                Capsule()
                    .fill(AppColors.background)
                    .skeuoSunken(cornerRadius: 15)
                    .frame(width: 50, height: 30)
                
                // 拨杆按钮
                Circle()
                    .fill(configuration.isOn ? Color.orange : AppColors.background)
                    .skeuoRaised(cornerRadius: 13)
                    .frame(width: 26, height: 26)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isOn)
            }
            .onTapGesture { configuration.isOn.toggle() }
        }
    }
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
                    .shadow(color: AppColors.shadowLight, radius: 8, x: -4, y: -4)
                    .shadow(color: AppColors.shadowDark, radius: 8, x: 4, y: 4)
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
                    
                    // 🚀 核心修复：1:1 还原 Figma 内阴影效果
                    // 右下深色
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(AppColors.shadowDark, lineWidth: 2)
                        .blur(radius: 4)
                        .offset(x: 2, y: 2)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                    
                    // 左上亮色
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(AppColors.shadowLight, lineWidth: 2)
                        .blur(radius: 4)
                        .offset(x: -2, y: -2)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)))
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

// MARK: - UIColor 扩展
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r, g, b, a: CGFloat
        let length = hexSanitized.count

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
