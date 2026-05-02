import SwiftUI

struct LyricsView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background Surface - 9893:14777
            DesignTokens.surfaceMain.ignoresSafeArea()
            
            // 2. Paper Sheet (Scrolling Content) - 9893:14779
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        Spacer(minLength: 120) // Buffer for roller
                        
                        // Paper Container
                        Spacer(minLength: 120) // 滚轴缓冲间距
                        
                        // 纸张容器
                        VStack(spacing: 32) {
                            ForEach(Array(player.currentTrackLyrics.enumerated()), id: \.offset) { index, line in
                                VStack(alignment: .leading, spacing: 8) {
                                    if index == player.currentLyricIndex {
                                        TypewriterText(text: line.text)
                                            .font(.custom("AmericanTypewriter-Bold", size: 24))
                                            .foregroundColor(DesignTokens.textPrimary)
                                            .id(index)
                                    } else {
                                        Text(line.text)
                                            .font(.custom("AmericanTypewriter", size: 18))
                                            .foregroundColor(DesignTokens.textSecondary.opacity(0.4))
                                            .id(index)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 40)
                            }
                        }
                        .padding(.vertical, 40)
                        .background(
                            Color.white
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 300)
                    }
                }
                .onChange(of: player.currentLyricIndex) { newIndex in
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
            
            // 1. 打印机滚轴 (顶部固定)
            Image("roller_light")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 100)
                .skeuoRaised(cornerRadius: 0)
                .overlay(
                    HStack {
                        // 左旋钮
                        Circle()
                            .fill(DesignTokens.surfaceMain)
                            .skeuoRaised(cornerRadius: 30)
                            .frame(width: 60, height: 60)
                            .overlay(Image(systemName: "gear").foregroundColor(DesignTokens.textSecondary))
                            .offset(x: -30)
                        
                        Spacer()
                        
                        // 右旋钮
                        Circle()
                            .fill(DesignTokens.surfaceMain)
                            .skeuoRaised(cornerRadius: 30)
                            .frame(width: 60, height: 60)
                            .overlay(Image(systemName: "gear").foregroundColor(DesignTokens.textSecondary))
                            .offset(x: 30)
                    }
                )
                .zIndex(10)
            
            // 3. 顶部栏
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("<").font(.system(size: 20, weight: .bold))
                }
                Spacer()
                Text("LYRICS")
                    .font(.system(size: 16, weight: .black))
                Spacer()
                Image(systemName: "printer.fill")
                    .font(.system(size: 18))
            }
            .foregroundColor(DesignTokens.textPrimary)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .zIndex(20)
        }
        .navigationBarHidden(true)
    }
}

struct TypewriterText: View {
    let text: String
    @State private var displayedText: String = ""
    @State private var timer: Timer?
    
    var body: some View {
        Text(displayedText)
            .onAppear { startTyping() }
            .onChange(of: text) { _ in startTyping() }
            .onDisappear { timer?.invalidate() }
    }
    
    private func startTyping() {
        displayedText = ""
        timer?.invalidate()
        var index = 0
        let characters = Array(text)
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            if index < characters.count {
                displayedText.append(characters[index])
                index += 1
            } else { t.invalidate() }
        }
    }
}
