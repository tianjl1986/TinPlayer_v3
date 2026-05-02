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
    
    var vinylBlack: Color {
        Color(hex: "#09090b")
    }
    
    var separator: Color {
        currentTheme == .light ? Color(hex: "#d4d4d8") : Color(hex: "#27272a")
    }
}

struct AppColors {
    static var background: Color { ThemeManager.shared.background }
    static var textPrimary: Color { ThemeManager.shared.textPrimary }
    static var textSecondary: Color { ThemeManager.shared.textSecondary }
    static var separator: Color { ThemeManager.shared.separator }
    static var shadowLight: Color { ThemeManager.shared.shadowLight }
    static var shadowDark: Color { ThemeManager.shared.shadowDark }
    static var vinylBlack: Color { ThemeManager.shared.vinylBlack }
}

struct SkeuoToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            ZStack {
                Capsule()
                    .fill(AppColors.background)
                    .skeuoSunken(cornerRadius: 15)
                    .frame(width: 50, height: 30)
                
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

struct SkeuoRaised: ViewModifier {
    var cornerRadius: CGFloat
    @ObservedObject var themeManager = ThemeManager.shared
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(themeManager.background)
                    .shadow(color: themeManager.shadowLight, radius: 8, x: -4, y: -4)
                    .shadow(color: themeManager.shadowDark, radius: 8, x: 4, y: 4)
            )
    }
}

struct SkeuoSunken: ViewModifier {
    var cornerRadius: CGFloat
    @ObservedObject var themeManager = ThemeManager.shared
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(themeManager.background)
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(themeManager.shadowDark, lineWidth: 2)
                        .blur(radius: 4)
                        .offset(x: 2, y: 2)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(themeManager.shadowLight, lineWidth: 2)
                        .blur(radius: 4)
                        .offset(x: -2, y: -2)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius).fill(LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)))
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func skeuoRaised(cornerRadius: CGFloat = 12) -> some View {
        modifier(SkeuoRaised(cornerRadius: cornerRadius))
    }
    func skeuoSunken(cornerRadius: CGFloat = 12) -> some View {
        modifier(SkeuoSunken(cornerRadius: cornerRadius))
    }
}
