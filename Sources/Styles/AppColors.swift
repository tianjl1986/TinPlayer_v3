import SwiftUI

struct AppColors {
    // 🚀 1:1 像素级颜色还原 (Zinc 深色调)
    static let background = Color(hex: "#09090b")
    static let cardBackground = Color(hex: "#18181b")
    static let border = Color(hex: "#27272a")
    
    // 文字颜色
    static let textPrimary = Color(hex: "#fafafa")
    static let textSecondary = Color(hex: "#a1a1aa")
    static let textActive = Color(hex: "#f97316") // 橙色强调
    
    // 渐变
    static let navBarGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "#18181b"), location: 0),
            .init(color: Color(hex: "#09090b"), location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
