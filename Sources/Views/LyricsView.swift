import SwiftUI

struct LyricsView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Figma 1:1 几何参数
    private let rollerHeight: CGFloat = 40
    private let knobSize: CGSize = CGSize(width: 48, height: 48)
    private let paperWidth: CGFloat = 320
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header (60px)
            AppHeader(
                title: "LYRICS",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textSecondary)
                    }
                )
            )
            .padding(.horizontal, 24)
            
            // 2. 机械打字机区域
            ZStack(alignment: .top) {
                // 纸张
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 32) {
                            Spacer(minLength: 160)
                            
                            if player.currentTrackLyrics.isEmpty {
                                Text("NO LYRICS...")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(DesignTokens.textSecondary.opacity(0.2))
                                    .frame(maxWidth: .infinity)
                            } else {
                                ForEach(Array(player.currentTrackLyrics.enumerated()), id: \.offset) { index, line in
                                    TypewriterText(
                                        text: line.text,
                                        isCurrent: index == player.currentLyricIndex,
                                        isPast: index < player.currentLyricIndex
                                    )
                                    .id(index)
                                }
                            }
                            
                            Spacer(minLength: 300)
                        }
                        .frame(width: paperWidth, alignment: .leading)
                        .background(Color.white)
                        .padding(.top, 20)
                    }
                    .onChange(of: player.currentLyricIndex) { newIndex in
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                .frame(width: paperWidth)
                .background(Color.white)
                .skeuoRaised(cornerRadius: 0)
                .offset(y: 30)
                .zIndex(0)
                
                // 滚轴组件 (Roller Assembly)
                HStack(spacing: 0) {
                    // 左旋钮
                    ZStack {
                        Circle()
                            .fill(DesignTokens.surfaceMain)
                            .skeuoRaised(cornerRadius: 24)
                            .frame(width: knobSize.width, height: knobSize.height)
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                            .frame(width: 24, height: 24) // Fixed frame for rotation center
                            .rotationEffect(.degrees(player.currentTime * 90))
                    }
                    .offset(x: -10)
                    
                    // 滚轴主体
                    Rectangle()
                        .fill(DesignTokens.rollerGradient)
                        .frame(height: rollerHeight)
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        )
                    
                    // 右旋钮
                    ZStack {
                        Circle()
                            .fill(DesignTokens.surfaceMain)
                            .skeuoRaised(cornerRadius: 24)
                            .frame(width: knobSize.width, height: knobSize.height)
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                            .frame(width: 24, height: 24) // Fixed frame for rotation center
                            .rotationEffect(.degrees(player.currentTime * 90))
                    }
                    .offset(x: 10)
                }
                .padding(.horizontal, 10)
                .zIndex(1)
            }
            .frame(maxHeight: .infinity)
            
            // 3. 底部进度
            VStack(spacing: 24) {
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
                    .padding(.horizontal, 32)
                }
                
                BottomControlsView()
                    .padding(.bottom, 48)
            }
            .background(DesignTokens.surfaceMain)
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
    }
}

struct TypewriterText: View {
    let text: String
    let isCurrent: Bool
    let isPast: Bool
    
    @State private var visibleCount: Int = 0
    @State private var timer: Timer?
    
    var body: some View {
        HStack(spacing: 0) {
            Text(String(text.prefix(visibleCount)))
                .font(.custom("AmericanTypewriter-Bold", size: 22))
                .foregroundColor(isCurrent ? DesignTokens.textPrimary : DesignTokens.textSecondary)
                .opacity(isPast ? 0.3 : (isCurrent ? 1.0 : 0.6))
                .multilineTextAlignment(.leading)
            
            if isCurrent && visibleCount < text.count {
                Rectangle()
                    .fill(DesignTokens.textActive)
                    .frame(width: 2, height: 24)
                    .opacity(0.8)
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Ensure leading alignment
        .padding(.horizontal, 40)
        .onAppear {
            if isCurrent { startTyping() }
            else { visibleCount = text.count }
        }
        .onChange(of: isCurrent) { newValue in
            if newValue { startTyping() }
            else { visibleCount = text.count }
        }
    }
    
    private func startTyping() {
        visibleCount = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            if visibleCount < text.count {
                visibleCount += 1
            } else {
                t.invalidate()
            }
        }
    }
}
