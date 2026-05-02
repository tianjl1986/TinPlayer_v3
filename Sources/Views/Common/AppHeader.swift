import SwiftUI

// MARK: - AppHeader（严格按Figma设计：高度60，左中右三区）
struct AppHeader: View {
    @ObservedObject var themeManager = ThemeManager.shared
    let title: String
    var leftItem: AnyView? = nil
    var rightItem: AnyView? = nil

    var body: some View {
        ZStack {
            // 居中标题：Inter Bold 14pt，letterSpacing 2
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(themeManager.textPrimary)
                .tracking(2)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                if let left = leftItem {
                    left
                } else {
                    Color.clear.frame(width: 40)
                }
                Spacer()
                if let right = rightItem {
                    right
                } else {
                    Color.clear.frame(width: 40)
                }
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 24)
        .background(themeManager.background)
    }
}
