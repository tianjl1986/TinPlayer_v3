import SwiftUI

struct NowPlayingView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header (60px height) - 9880:14736
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                }
                
                Spacer()
                
                Text("NOW PLAYING")
                    .font(.system(size: 14, weight: .black))
                    .tracking(2)
                    .foregroundColor(DesignTokens.textPrimary)
                
                Spacer()
                
                Button(action: { /* More action */ }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                }
            }
            .frame(height: 60)
            .padding(.horizontal, 24)
            
            // Spacing: 32px (92 - 60)
            Spacer().frame(height: 32)
            
            // 2. 黑胶唱机 (400px height) - 9880:14740
            VinylTurntableView()
                .frame(maxWidth: .infinity)
            
            // Spacing: 65px (557 - 492)
            Spacer().frame(height: 65)
            
            // 3. 歌曲信息 (56px height) - 9880:14741
            VStack(spacing: 8) {
                Text(player.currentTrack?.title.uppercased() ?? "SKEUOMORPHIC DREAMS")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                    .lineLimit(1)
                
                Text(player.currentTrack?.artist.uppercased() ?? "THE VINYL ORCHESTRA")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
                    .lineLimit(1)
            }
            .frame(height: 56)
            .padding(.horizontal, 40)
            
            // Spacing: 48px (661 - 613)
            Spacer().frame(height: 48)
            
            // 4. 进度条 (15px height) - 9880:14744
            VStack(spacing: 12) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(DesignTokens.surfaceMain)
                            .skeuoSunken(cornerRadius: 4)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hexString: "#404040"))
                            .frame(width: max(0, geo.size.width * CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1))), height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.leading, 72)
                .padding(.trailing, 74) // 精确匹配 244px 宽度
                
                HStack {
                    Text(formatDuration(player.currentTime))
                    Spacer()
                    Text(formatDuration(player.duration))
                }
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(DesignTokens.textSecondary)
                .padding(.horizontal, 32)
            }
            .frame(height: 15)
            
            // Spacing: 48px (724 - 676)
            Spacer().frame(height: 48)
            
            // 5. 控制面板 (72px height) - 9880:14748
            BottomControlsView()
                .padding(.bottom, 48)
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
    }
}
