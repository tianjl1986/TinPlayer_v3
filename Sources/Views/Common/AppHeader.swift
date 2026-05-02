import SwiftUI

struct AppHeader: View {
    let title: String
    let leftItem: AnyView?
    let rightItem: AnyView?
    
    // 1:1 鍍忕礌绾ц璁″弬鏁?    private let headerHeight: CGFloat = 64
    private let horizontalPadding: CGFloat = 24
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Action Area
            if let left = leftItem {
                left
                    .frame(width: 44, height: 44)
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // Title (Pixel-Perfect Typography)
            Text(title.uppercased())
                .font(.system(size: 15, weight: .black))
                .kerning(2.5) // Figma 閲岀殑瀛楃闂磋窛
                .foregroundColor(DesignTokens.textPrimary)
            
            Spacer()
            
            // Right Action Area
            if let right = rightItem {
                right
                    .frame(width: 44, height: 44)
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: headerHeight)
        .padding(.top, 10) // 鑰冭檻鍒板垬娴峰睆鐨勮瑙夐噸蹇冨亸绉?    }
}
