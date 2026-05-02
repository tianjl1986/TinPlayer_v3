import SwiftUI

// MARK: - 主题模式
enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
}

// MARK: - 全局便捷颜色访问 (1:1 设计还原)
struct AppColors {
    static var background: Color { ThemeManager.shared.background }
    static var textPrimary: Color { ThemeManager.shared.textPrimary }
    static var textSecondary: Color { ThemeManager.shared.textSecondary }
    static var textActive: Color { Color.orange }
    static var shadowLight: Color { ThemeManager.shared.shadowLight }
    static var shadowDark: Color { ThemeManager.shared.shadowDark }
}

// MARK: - 颜色系统（支持主题切换）
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("appTheme") var currentTheme: AppTheme = .light
    
    var background: Color {
        currentTheme == .light ? Color(hex: "#f2f2f2") : Color(hex: "#121212")
    }
    
    var textPrimary: Color {
        currentTheme == .light ? Color(hex: "#1a1a1a") : Color(hex: "#fafafa")
    }
    
    var textSecondary: Color {
        currentTheme == .light ? Color(hex: "#808080") : Color(hex: "#a1a1aa")
    }
    
    var shadowLight: Color {
        currentTheme == .light ? Color.white : Color(hex: "#1e1e1e")
    }
    
    var shadowDark: Color {
        currentTheme == .light ? Color(hex: "#b3b3b3") : Color(hex: "#000000")
    }
}

// MARK: - 全局公用工具函数
public func formatDuration(_ time: TimeInterval) -> String {
    guard time.isFinite && !time.isNaN && time >= 0 else { return "00:00" }
    let mins = Int(time) / 60
    let secs = Int(time) % 60
    return String(format: "%02d:%02d", mins, secs)
}

// MARK: - 拟物化组件样式
struct SkeuoToggleStyle: ToggleStyle {
    @ObservedObject var themeManager = ThemeManager.shared
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.textPrimary)
            Spacer()
            Button(action: { configuration.isOn.toggle() }) {
                ZStack {
                    Capsule()
                        .fill(themeManager.background)
                        .skeuoSunken(cornerRadius: 15)
                        .frame(width: 54, height: 28)
                    
                    Circle()
                        .fill(configuration.isOn ? Color.orange : themeManager.textSecondary.opacity(0.3))
                        .skeuoRaised(cornerRadius: 12)
                        .frame(width: 24, height: 24)
                        .offset(x: configuration.isOn ? 13 : -13)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct SkeuoRaised: ViewModifier {
    var cornerRadius: CGFloat
    var radius: CGFloat
    var offset: CGFloat
    @ObservedObject var themeManager = ThemeManager.shared
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(themeManager.background)
                    .shadow(color: themeManager.shadowLight, radius: radius, x: -offset, y: -offset)
                    .shadow(color: themeManager.shadowDark, radius: radius, x: offset, y: offset)
            )
    }
}

struct SkeuoSunken: ViewModifier {
    var cornerRadius: CGFloat
    var radius: CGFloat
    var offset: CGFloat
    @ObservedObject var themeManager = ThemeManager.shared
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(themeManager.background)
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(themeManager.shadowDark, lineWidth: 2)
                        .blur(radius: radius)
                        .offset(x: offset, y: offset)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(themeManager.shadowLight, lineWidth: 2)
                        .blur(radius: radius)
                        .offset(x: -offset, y: -offset)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func skeuoRaised(cornerRadius: CGFloat = 12, radius: CGFloat = 8, offset: CGFloat = 4) -> some View {
        modifier(SkeuoRaised(cornerRadius: cornerRadius, radius: radius, offset: offset))
    }
    func skeuoSunken(cornerRadius: CGFloat = 12, radius: CGFloat = 4, offset: CGFloat = 2) -> some View {
        modifier(SkeuoSunken(cornerRadius: cornerRadius, radius: radius, offset: offset))
    }
}

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
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
