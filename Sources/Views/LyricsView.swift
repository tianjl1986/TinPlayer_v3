import SwiftUI

struct LyricsView: View {
    @ObservedObject var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var knobRotation: Double = 0
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    // 🚀 Figma 1:1 精确几何参数
    private let rollerHeight: CGFloat = 60
    private let knobSize: CGFloat = 64
    private let paperWidth: CGFloat = 340
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header - Standardized
            AppHeader(
                title: "LYRICS",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { /* More */ }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            // 2. Paper & Roller Area
            ZStack(alignment: .top) {
                // Paper
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 32) {
                            Spacer(minLength: 120) // Spacing for roller
                            
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
                            
                            Spacer(minLength: 300) // Extra bottom padding for "paper bottom clipped" fix
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
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
                        Color.white
                        Image("paper_texture_light") // Subtle texture if available
                            .resizable()
                            .opacity(0.05)
                    }
                )
                .cornerRadius(4)
                .skeuoRaised(cornerRadius: 4)
                .offset(y: 40)
                .zIndex(0)
                
                // Roller Assembly
                HStack(spacing: -15) {
                    knobView
                    
                    ZStack {
                        Image("roller_light")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: rollerHeight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .skeuoRaised(cornerRadius: 12)
                        
                        // Mechanical shadow overlay
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.1), Color.clear, Color.black.opacity(0.15)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: rollerHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .frame(maxWidth: .infinity)
                    
                    knobView
                }
                .padding(.horizontal, 16)
                .zIndex(1)
            }
            .frame(maxHeight: .infinity)
            
            // 3. Progress & Controls - Visual Consistency
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
                
                BottomControlsView()
                    .padding(.bottom, 40)
            }
            .padding(.top, 24)
            .background(DesignTokens.surfaceMain)
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            if player.isPlaying {
                withAnimation(.linear(duration: 0.1)) {
                    knobRotation += 12
                }
            }
        }
    }
    
    private var knobView: some View {
        Image("knob_light")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: knobSize, height: knobSize)
            .rotationEffect(.degrees(knobRotation))
            .skeuoRaised(cornerRadius: 32)
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
