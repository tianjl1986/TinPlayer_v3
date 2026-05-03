import SwiftUI

struct LyricsView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Figma 1:1 几何参数
    private let rollerHeight: CGFloat = 40
    private let knobSize: CGSize = CGSize(width: 30, height: 60)
    private let paperWidth: CGFloat = 342
    private let lineSpacing: CGFloat = 32
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header (60px) - 9893:14778
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textSecondary)
                }
                Spacer()
                Text("LYRICS")
                    .font(.system(size: 14, weight: .black))
                    .tracking(2)
                Spacer()
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
            }
            .frame(height: 60)
            .padding(.horizontal, 24)
            
            // 2. 机械打字机滚轴区域 (Platen Roller Area)
            ZStack(alignment: .top) {
                // 纸张 (Paper Sheet) - 9893:14779
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: lineSpacing) {
                            Spacer(minLength: 140) // 初始偏移
                            
                            if player.currentTrackLyrics.isEmpty {
                                Text("NO LYRICS AVAILABLE")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(DesignTokens.textSecondary.opacity(0.3))
                                    .padding(.top, 100)
                            } else {
                                ForEach(Array(player.currentTrackLyrics.enumerated()), id: \.offset) { index, line in
                                    LyricRow(
                                        text: line.text,
                                        isCurrent: index == player.currentLyricIndex,
                                        isPast: index < player.currentLyricIndex
                                    )
                                    .id(index)
                                }
                            }
                            
                            Spacer(minLength: 300)
                        }
                    }
                    .onChange(of: player.currentLyricIndex) { newIndex in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                .frame(width: paperWidth)
                .background(Color(hexString: "#FAFAFA"))
                .skeuoRaised(cornerRadius: 12)
                .offset(y: 40) // 从滚轴下方穿出
                
                // 滚轴组件 (Roller Assembly) - 9893:14780
                HStack(spacing: 0) {
                    // 左旋钮 (Knob Left)
                    Image("knob_light")
                        .resizable()
                        .frame(width: knobSize.width, height: knobSize.height)
                        .rotationEffect(.degrees(player.currentTime * 30))
                        .offset(y: -10)
                    
                    // 滚轴主体 (Roller)
                    Rectangle()
                        .fill(DesignTokens.rollerGradient)
                        .frame(height: rollerHeight)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.2), lineWidth: 1)
                        )
                        .skeuoRaised(cornerRadius: 4)
                    
                    // 右旋钮 (Knob Right)
                    Image("knob_light")
                        .resizable()
                        .frame(width: knobSize.width, height: knobSize.height)
                        .rotationEffect(.degrees(player.currentTime * 30))
                        .offset(y: -10)
                }
                .padding(.horizontal, 4)
                .zIndex(1)
            }
            
            Spacer()
            
            // 3. 底部进度与控制
            VStack(spacing: 24) {
                // 进度条
                VStack(spacing: 8) {
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
                }
                .padding(.horizontal, 32)
                
                BottomControlsView()
                    .padding(.bottom, 48)
            }
            .background(DesignTokens.surfaceMain)
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
    }
}

struct LyricRow: View {
    let text: String
    let isCurrent: Bool
    let isPast: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isCurrent {
                TypewriterText(text: text, isAnimating: true)
                    .font(.custom("AmericanTypewriter-Bold", size: 24))
                    .foregroundColor(DesignTokens.textPrimary)
            } else {
                Text(text)
                    .font(.custom("AmericanTypewriter", size: isPast ? 16 : 20))
                    .foregroundColor(DesignTokens.textPrimary.opacity(isPast ? 0.3 : 0.6))
                    .scaleEffect(isPast ? 0.95 : 1.0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 20)
        .animation(.spring(), value: isCurrent)
    }
}

struct TypewriterText: View {
    let text: String
    let isAnimating: Bool
    @State private var displayedText: String = ""
    @State private var timer: Timer?
    
    var body: some View {
        Text(displayedText)
            .onAppear { if isAnimating { startTyping() } else { displayedText = text } }
            .onChange(of: text) { _ in if isAnimating { startTyping() } else { displayedText = text } }
            .onDisappear { timer?.invalidate() }
    }
    
    private func startTyping() {
        displayedText = ""
        timer?.invalidate()
        let characters = Array(text)
        var index = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { t in
            if index < characters.count {
                displayedText.append(characters[index])
                index += 1
            } else {
                t.invalidate()
            }
        }
    }
}
