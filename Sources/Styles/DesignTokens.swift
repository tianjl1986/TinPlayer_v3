import SwiftUI

struct DesignTokens {
    // 1. Dynamic Backgrounds
    static let surfaceMain = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(hexString: "#121212") : UIColor(hexString: "#F0F0F0")
    })
    
    static let surfaceSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(hexString: "#000000") : UIColor(hexString: "#FFFFFF")
    })
    
    // 2. Text Colors
    static let textPrimary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
    })
    
    static let textSecondary = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(hexString: "#8E8E93") : UIColor(hexString: "#666666")
    })
    
    static let textActive = Color.blue // Accent color
    
    // 3. Specialized Colors for Skeuomorphism
    static let skeuoShadowLight = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.05) : UIColor.white
    })
    
    static let skeuoShadowDark = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.black.withAlphaComponent(0.8) : UIColor(hexString: "#D1D9E6")
    })
    
    // 4. Backward Compatibility Aliases
    static var surfaceLight: Color { surfaceMain }
    static var background: Color { surfaceMain }
}

// Helper for Hex Colors
extension Color {
    init(hexString: String) {
        self.init(UIColor(hexString: hexString))
    }
}

// Helper for Hex Colors
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
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
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
