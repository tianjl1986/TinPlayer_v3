import SwiftUI

struct LyricsView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. Background Surface
            DesignTokens.surfaceMain.ignoresSafeArea()
            
            // 2. Paper Sheet (Scrolling Content)
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: 140) // Buffer for roller
                        
                        // Paper Sheet
                        VStack(spacing: 32) {
                            ForEach(Array(player.currentTrackLyrics.enumerated()), id: \.offset) { index, line in
                                LyricRow(
                                    text: line.text,
                                    isCurrent: index == player.currentLyricIndex,
                                    isPast: index < player.currentLyricIndex
                                )
                                .id(index)
                            }
                        }
                        .padding(.vertical, 60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Color.white
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 10)
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 400)
                    }
                }
                .onChange(of: player.currentLyricIndex) { newIndex in
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
            
            // 3. Printer Roller (Top Fixed) - 10491:8476
            VStack(spacing: 0) {
                ZStack {
                    Image("roller_light")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    HStack {
                        // Left Knob
                        Image("knob_light")
                            .resizable()
                            .frame(width: 56, height: 56)
                            .skeuoRaised(cornerRadius: 28)
                            .rotationEffect(.degrees(player.currentTime * 30))
                            .offset(x: -20)
                        
                        Spacer()
                        
                        // Right Knob
                        Image("knob_light")
                            .resizable()
                            .frame(width: 56, height: 56)
                            .skeuoRaised(cornerRadius: 28)
                            .rotationEffect(.degrees(player.currentTime * 30))
                            .offset(x: 20)
                    }
                }
                
    // Figma 1:1 几何参数
    private let rollerHeight: CGFloat = 40
    private let knobSize: CGSize = CGSize(width: 30, height: 60)
    private let paperWidth: CGFloat = 342
    private let lineSpacing: CGFloat = 52
    
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
                // Figma: y:100, w:342
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: lineSpacing) {
                            Spacer().frame(height: 140) // 初始偏移
                            
                            ForEach(0..<player.lyrics.count, id: \.self) { index in
                                let isCurrent = player.currentLyricIndex == index
                                let isPast = index < player.currentLyricIndex
                                
                                TypewriterText(
                                    text: player.lyrics[index].text,
                                    isAnimating: isCurrent
                                )
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(isCurrent ? DesignTokens.textPrimary : DesignTokens.textSecondary)
                                .opacity(isCurrent ? 1.0 : (isPast ? 0.3 : 0.6))
                                .scaleEffect(isCurrent ? 1.05 : 1.0)
                                .multilineTextAlignment(.center)
                                .id(index)
                                .animation(.spring(), value: player.currentLyricIndex)
                            }
                            
                            Spacer().frame(height: 300)
                        }
                    }
                    .onChange(of: player.currentLyricIndex) { index in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            proxy.scrollTo(index, anchor: .center)
                        }
                    }
                }
                .frame(width: paperWidth)
                .background(Color(hexString: "#FAFAFA"))
                .skeuoRaised(cornerRadius: 12)
                .offset(y: 40) // 从滚轴下方穿出
                
                // 滚轴组件 (Roller Assembly) - 9893:14780
                HStack(spacing: 0) {
                    // 左旋钮 (Knob Left) - 9960:15442
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
                    
                    // 右旋钮 (Knob Right) - 9960:15443
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
            
            // 3. 底部进度与控制 (对齐 NowPlayingView)
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
                                .frame(width: geo.size.width * CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)), height: 8)
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
                    .foregroundColor(DesignTokens.textPrimary.opacity(isPast ? 0.3 : 0.1))
                    .scaleEffect(isPast ? 0.95 : 1.0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 40)
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
            .onChange(of: text) { _ in startTyping() }
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
                // 模拟机械打字机的微小抖动或随机延迟 (可选)
            } else {
                t.invalidate()
            }
        }
    }
}
