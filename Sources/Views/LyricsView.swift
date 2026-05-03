import SwiftUI

struct LyricsView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var theme = ThemeManager.shared
    @Binding var showLyrics: Bool
    @State private var knobRotation: Double = 0
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    // 🚀 Figma 1:1 精确几何参数
    private let rollerHeight: CGFloat = 36
    private let knobSize: CGFloat = 48
    private let paperWidth: CGFloat = 320
    
    var body: some View {
        GeometryReader { fullGeo in
            VStack(spacing: 0) {
                // 1. Header - Standardized with Dropdown Arrow
                AppHeader(
                    title: "LYRICS",
                    leftItem: AnyView(
                        Button(action: { showLyrics = false }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(DesignTokens.textPrimary)
                        }
                    )
                )
                
                // 2. Paper & Roller Area
                ZStack(alignment: .top) {
                    // Transparent layer for "click empty space to dismiss"
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { showLyrics = false }
                        .zIndex(0)
                    
                    // Paper
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 32) {
                                Spacer(minLength: 100) // Spacing for roller
                                
                                if player.currentTrackLyrics.isEmpty {
                                    Text("NO LYRICS FOUND")
                                        .font(.system(size: 14, weight: .black))
                                        .foregroundColor(DesignTokens.textSecondary.opacity(0.3))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 100)
                                } else {
                                    ForEach(Array(player.currentTrackLyrics.enumerated()), id: \.offset) { index, line in
                                        TypewriterText(
                                            text: line.text,
                                            isCurrent: index == player.currentLyricIndex
                                        )
                                        .id(index)
                                    }
                                }
                                
                                Spacer(minLength: 120) // Reduced to avoid too much scrolling at bottom
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 28)
                        }
                        .onChange(of: player.currentLyricIndex) { newIndex in
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                    .frame(width: paperWidth)
                    .background(
                        ZStack {
                            theme.isDark ? Color(hexString: "#262626") : Color.white
                            Image("paper_texture_light")
                                .resizable()
                                .opacity(0.05)
                        }
                    )
                    .cornerRadius(4)
                    .skeuoRaised(cornerRadius: 4)
                    .offset(y: 30)
                    .padding(.bottom, 20) // Ensure bottom is not clipped
                    .zIndex(1)
                    
                    // Roller Assembly - Fixed geometry 1:1
                    HStack(spacing: -8) { // Overlap for tight mechanical look
                        knobView
                        
                        ZStack {
                            Image(theme.isDark ? "roller_dark" : "roller_light")
                                .resizable()
                                .aspectRatio(contentMode: .stretch)
                                .frame(width: paperWidth, height: rollerHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .skeuoRaised(cornerRadius: 4)
                            
                            DesignTokens.rollerGradient
                                .frame(width: paperWidth, height: rollerHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .opacity(0.4)
                        }
                        
                        knobView
                    }
                    .frame(width: fullGeo.size.width)
                    .offset(y: 10)
                    .zIndex(2)
                }
                .frame(maxHeight: .infinity)
                
                // 3. Progress & Controls
                VStack(spacing: 24) {
                    HStack(spacing: 12) {
                        Text(formatDuration(player.currentTime))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(DesignTokens.textSecondary)
                            .frame(width: 45, alignment: .leading)
                        
                        progressBar
                        
                        Text(formatDuration(player.duration))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(DesignTokens.textSecondary)
                            .frame(width: 45, alignment: .trailing)
                    }
                    .padding(.horizontal, 32)
                    
                    BottomControlsView(showLyrics: $showLyrics)
                        .padding(.bottom, 32)
                }
                .padding(.top, 20)
                .background(DesignTokens.surfaceMain)
            }
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private var knobView: some View {
        Image(theme.isDark ? "knob_dark" : "knob_light")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: knobSize, height: knobSize)
            .skeuoRaised(cornerRadius: knobSize/2)
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.1))
                    .frame(height: 8)
                    .skeuoSunken(cornerRadius: 6)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(DesignTokens.textActive)
                    .frame(width: geo.size.width * CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)), height: 8)
            }
        }
        .frame(height: 8)
    }
}
