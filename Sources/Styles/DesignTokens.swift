import SwiftUI

struct DesignTokens {
    // Surface Colors from Section 10249:2
    static let surfaceMain = Color(hexString: "#e5e5e5")      // Skeuo Main Surface
    static let surfaceSecondary = Color(hexString: "#fafafa") // Secondary Surface
    static let surfaceLight = Color(hexString: "#f2f2f2")     // WF Fill Light (Library/Settings)
    static let background = surfaceMain
    
    // Text Colors
    static let textPrimary = Color(hexString: "#1a1a1a")      // Text-Primary
    static let textSecondary = Color(hexString: "#808080")    // Text-Secondary
    static let textActive = Color(hexString: "#3b82f6")       // Active/Accent (Blue)
    
    // Skeuomorphic Shadows
    static let shadowDark = Color(hexString: "#b3b3b3")       // For Raised/Sunken effect
    static let shadowLight = Color.white                      // For Highlights
    
    // Gradients - 1:1 Figma Angular
    static let vinylGradient = AngularGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hexString: "#1A1A1A"), location: 0),
            .init(color: Color(hexString: "#4D4D4D"), location: 0.25),
            .init(color: Color(hexString: "#1A1A1A"), location: 0.5),
            .init(color: Color(hexString: "#4D4D4D"), location: 0.75),
            .init(color: Color(hexString: "#1A1A1A"), location: 1)
        ]),
        center: .center
    )
    
    static let spindleGradient = AngularGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hexString: "#999999"), location: 0),
            .init(color: Color(hexString: "#E5E5E5"), location: 0.25),
            .init(color: Color(hexString: "#999999"), location: 0.5),
            .init(color: Color(hexString: "#E5E5E5"), location: 0.75),
            .init(color: Color(hexString: "#999999"), location: 1)
        ]),
        center: .center
    )

    static let rollerGradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: Color(hexString: "#0D0D0D"), location: 0),
            .init(color: Color(hexString: "#333333"), location: 0.2),
            .init(color: Color(hexString: "#1A1A1A"), location: 0.5),
            .init(color: Color(hexString: "#333333"), location: 0.8),
            .init(color: Color(hexString: "#0D0D0D"), location: 1)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}

extension View {
    func skeuoRaised(cornerRadius: CGFloat = 16) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(DesignTokens.surfaceMain)
                .shadow(color: DesignTokens.shadowLight, radius: 8, x: -4, y: -4)
                .shadow(color: DesignTokens.shadowDark, radius: 8, x: 4, y: 4)
        )
    }
    
    func skeuoSunken(cornerRadius: CGFloat = 16) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(DesignTokens.surfaceMain)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(DesignTokens.shadowDark, lineWidth: 2)
                        .blur(radius: 4)
                        .offset(x: 2, y: 2)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(DesignTokens.shadowLight, lineWidth: 2)
                        .blur(radius: 4)
                        .offset(x: -2, y: -2)
                        .mask(RoundedRectangle(cornerRadius: cornerRadius))
                )
        )
    }
}

extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
