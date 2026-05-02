import SwiftUI

struct LyricsView: View {
    @ObservedObject var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 🚀 1. 打字机卷纸器 (Figma 9883:14782)
                typewriterHeader
                
                // 🚀 2. 歌词纸张区域
                ZStack {
                    // 纸张底色与纹理
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#fdfcf8")) // 象牙白纸张色
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    
                    // 纸张上的横线
                    VStack(spacing: 24) {
                        ForEach(0..<20) { _ in
                            Divider().background(Color.blue.opacity(0.05))
                        }
                    }
                    .padding(.top, 40)
                    
                    // 歌词滚动
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 32) {
                                Spacer(minLength: 120)
                                if !player.currentTrackLyrics.isEmpty {
                                    ForEach(player.currentTrackLyrics.indices, id: \.self) { index in
                                        Text(player.currentTrackLyrics[index].text)
                                            .font(.custom("Courier-Bold", size: 20))
                                            .foregroundColor(index == player.currentLyricIndex ? Color(hex: "#18181b") : Color(hex: "#a1a1aa"))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 40)
                                            .scaleEffect(index == player.currentLyricIndex ? 1.05 : 1.0)
                                            .animation(.spring(), value: player.currentLyricIndex)
                                            .id(index)
                                    }
                                } else {
                                    Text("Scanning paper...")
                                        .font(.custom("Courier", size: 16))
                                        .foregroundColor(.gray)
                                }
                                Spacer(minLength: 200)
                            }
                        }
                        .onChange(of: player.currentLyricIndex) { newIndex in
                            withAnimation(.easeInOut(duration: 0.8)) {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                
                // 🚀 3. 打字机按键区 (底部控制)
                typewriterFooter
            }
        }
    }
    
    private var typewriterHeader: some View {
        ZStack {
            // 卷纸轴
            Capsule()
                .fill(LinearGradient(colors: [Color(hex: "#71717a"), Color(hex: "#27272a"), Color(hex: "#71717a")], startPoint: .top, endPoint: .bottom))
                .frame(height: 30)
            
            // 轴端旋钮
            HStack {
                Circle().fill(Color(hex: "#18181b")).frame(width: 44, height: 44)
                Spacer()
                Circle().fill(Color(hex: "#18181b")).frame(width: 44, height: 44)
            }
            .padding(.horizontal, -10)
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
        .zIndex(1)
    }
    
    private var typewriterFooter: some View {
        HStack(spacing: 20) {
            // 返回按钮 (打字机按键样式)
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.down")
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 54, height: 54)
                    .skeuoRaised(cornerRadius: 27)
            }
            
            Spacer()
            
            // 在线搜索按钮
            Button(action: { /* 触发歌词搜索 */ }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 54, height: 54)
                    .skeuoRaised(cornerRadius: 27)
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
    }
}
