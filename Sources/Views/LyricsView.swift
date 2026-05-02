import SwiftUI

struct LyricsView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                Text("LYRICS")
                    .font(.system(size: 14, weight: .black))
                    .kerning(2)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .overlay(
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(12)
                            .skeuoRaised(cornerRadius: 12)
                    }
                    .padding(.trailing, 24)
                }
            )
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // 🚀 核心更新：带打字机效果的歌词列表
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        Spacer(minLength: 60)
                        
                        ForEach(Array(player.currentTrackLyrics.enumerated()), id: \.offset) { index, line in
                            if index == player.currentLyricIndex {
                                // 当前行：打字机效果
                                TypewriterText(text: line.text)
                                    .font(.system(size: 24, weight: .black))
                                    .foregroundColor(AppColors.textActive)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    .id(index)
                            } else {
                                // 非当前行：普通渐变效果
                                Text(line.text)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.4))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                    .id(index)
                                    .animation(.easeInOut, value: player.currentLyricIndex)
                            }
                        }
                        
                        Spacer(minLength: 120)
                    }
                }
                .onChange(of: player.currentLyricIndex) { newIndex in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
            
            // Bottom Control Knob
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.background)
                        .skeuoSunken(cornerRadius: 35)
                        .frame(width: 70, height: 70)
                    
                    Image("knob")
                        .resizable()
                        .frame(width: 54, height: 54)
                        .rotationEffect(.degrees(Double(player.currentTime / (player.duration > 0 ? player.duration : 1)) * 270 - 135))
                        .skeuoRaised(cornerRadius: 27)
                }
                
                Text("CONTROL")
                    .font(.system(size: 10, weight: .black))
                    .kerning(1.5)
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.bottom, 40)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

// MARK: - 打字机效果组件
struct TypewriterText: View {
    let text: String
    @State private var displayedText: String = ""
    @State private var timer: Timer?
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                startTyping()
            }
            .onChange(of: text) { _ in
                startTyping()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
    
    private func startTyping() {
        displayedText = ""
        timer?.invalidate()
        
        var index = 0
        let characters = Array(text)
        
        // 模拟打字速度，可根据歌词时长动态调整
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            if index < characters.count {
                displayedText.append(characters[index])
                index += 1
            } else {
                t.invalidate()
            }
        }
    }
}
