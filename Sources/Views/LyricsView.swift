import SwiftUI

struct LyricsView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Figma 1:1 几何参数
    private let rollerHeight: CGFloat = 40
    private let knobSize: CGSize = CGSize(width: 48, height: 48)
    private let paperWidth: CGFloat = 340
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
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
            
            // 2. Typewriter Area
            ZStack(alignment: .top) {
                // Paper
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {
                            Spacer(minLength: 140)
                            
                            if player.currentTrackLyrics.isEmpty {
                                Text("NO LYRICS FOUND")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(DesignTokens.textSecondary.opacity(0.3))
                                    .frame(maxWidth: .infinity)
                            } else {
                                ForEach(Array(player.currentTrackLyrics.enumerated()), id: \.offset) { index, line in
                                    TypewriterText(
                                        text: line.text,
                                        isCurrent: index == player.currentLyricIndex
                                    )
                                    .id(index)
                                }
                            }
                            
                            Spacer(minLength: 300)
                        }
                        .frame(width: paperWidth - 60, alignment: .leading)
                        .padding(.horizontal, 30)
                        .background(Color.white)
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
                
                // Roller Assembly
                HStack(spacing: 0) {
                    Image("knob_light")
                        .resizable()
                        .frame(width: knobSize.width, height: knobSize.height)
                        .offset(x: -12)
                    
                    Image("roller_light")
                        .resizable()
                        .frame(height: rollerHeight)
                    
                    Image("knob_light")
                        .resizable()
                        .frame(width: knobSize.width, height: knobSize.height)
                        .offset(x: 12)
                }
                .padding(.horizontal, 8)
                .zIndex(1)
            }
            .frame(maxHeight: .infinity)
            
            // 3. Spacing and Controls
            VStack(spacing: 36) {
                // Progress Bar
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black.opacity(0.1))
                                .frame(height: 8)
                                .skeuoSunken(cornerRadius: 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(DesignTokens.textPrimary.opacity(0.7))
                                .frame(width: geo.size.width * CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 40)
                
                BottomControlsView()
                    .padding(.bottom, 40)
            }
            .padding(.top, 24)
            .background(DesignTokens.surfaceMain)
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
    }
}

struct TypewriterText: View {
    let text: String
    let isCurrent: Bool
    @State private var revealedCharacters: Int = 0
    
    var body: some View {
        Text(isCurrent ? String(text.prefix(revealedCharacters)) : text)
            .font(.system(size: 16, weight: isCurrent ? .black : .bold, design: .monospaced))
            .foregroundColor(isCurrent ? DesignTokens.textPrimary : DesignTokens.textSecondary.opacity(0.4))
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading) // Ensure leading alignment
            .onAppear {
                if isCurrent {
                    animate()
                }
            }
            .onChange(of: isCurrent) { current in
                if current {
                    revealedCharacters = 0
                    animate()
                }
            }
    }
    
    private func animate() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if revealedCharacters < text.count {
                revealedCharacters += 1
            } else {
                timer.invalidate()
            }
        }
    }
}
