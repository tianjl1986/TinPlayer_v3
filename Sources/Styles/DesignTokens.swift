import SwiftUI

struct AppColors {
    // Surface Colors from Section 10249:2
    static let surfaceMain = Color(hex: "#e5e5e5")      // Skeuo Main Surface
    static let surfaceSecondary = Color(hex: "#fafafa") // Secondary Surface
    static let surfaceLight = Color(hex: "#f2f2f2")     // WF Fill Light (Library/Settings)
    static let background = surfaceMain
    
    // Text Colors
    static let textPrimary = Color(hex: "#1a1a1a")      // Text-Primary
    static let textSecondary = Color(hex: "#808080")    // Text-Secondary
    static let textActive = Color(hex: "#3b82f6")       // Active/Accent (Blue)
    
    // Skeuomorphic Shadows
    static let shadowDark = Color(hex: "#b3b3b3")       // For Raised/Sunken effect
    static let shadowLight = Color.white                // For Highlights
}

extension View {
    func skeuoRaised(cornerRadius: CGFloat = 16) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(AppColors.surfaceMain)
                .shadow(color: AppColors.shadowLight, radius: 8, x: -4, y: -4)
                .shadow(color: AppColors.shadowDark, radius: 8, x: 4, y: 4)
        )
    }
    
    func skeuoSunken(cornerRadius: CGFloat = 16) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(AppColors.surfaceMain)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(AppColors.shadowDark, lineWidth: 2)
                        .blur(radius: 2)
                        .offset(x: 2, y: 2)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(AppColors.shadowLight, lineWidth: 2)
                        .blur(radius: 2)
                        .offset(x: -2, y: -2)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius))
                )
        )
    }
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
