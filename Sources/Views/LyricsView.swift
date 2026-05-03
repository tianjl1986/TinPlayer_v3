import SwiftUI

struct LyricsView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    // 🚀 Figma 1:1 精确几何参数
    private let rollerHeight: CGFloat = 54
    private let knobSize: CGSize = CGSize(width: 72, height: 72)
    private let paperWidth: CGFloat = 340
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header - Standardized with Library View
            AppHeader(
                title: "LYRICS",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            // 2. Typewriter Area
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
                            
                            Spacer(minLength: 400)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
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
                .cornerRadius(4)
                .skeuoRaised(cornerRadius: 4)
                .offset(y: 36)
                .zIndex(0)
                
                // Roller Assembly - Aspect Ratio Corrected
                GeometryReader { rollerGeo in
                    HStack(spacing: 0) {
                        Image("knob_light")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: knobSize.width, height: knobSize.height)
                        
                        Image("roller_light")
                            .resizable()
                            .aspectRatio(contentMode: .fill) // Fill to preserve texture aspect
                            .frame(width: rollerGeo.size.width - (knobSize.width * 2), height: rollerHeight)
                            .clipped()
                        
                        Image("knob_light")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: knobSize.width, height: knobSize.height)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(height: knobSize.height)
                .padding(.horizontal, 10)
                .zIndex(1)
            }
            .frame(maxHeight: .infinity)
            
            // 3. Spacing and Controls
            VStack(spacing: 24) {
                // Progress Bar with Times on Sides
                HStack(spacing: 12) {
                    Text(formatDuration(player.currentTime))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DesignTokens.textSecondary)
                        .frame(width: 40, alignment: .leading)
                    
                    progressBar
                    
                    Text(formatDuration(player.duration))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(DesignTokens.textSecondary)
                        .frame(width: 40, alignment: .trailing)
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
        .transaction { transaction in
            transaction.animation = nil // Disable entrance jitter
        }
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
