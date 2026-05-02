import SwiftUI

struct AppHeader: View {
    let title: String
    let leftItem: AnyView?
    let rightItem: AnyView?
    
    // 1:1 像素级设计参数
    private let headerHeight: CGFloat = 64
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
                .kerning(2.5) // Figma 里的字符间距
                .foregroundColor(AppColors.textPrimary)
            
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
        .padding(.top, 10) // 考虑到刘海屏的视觉重心偏移
    }
}
