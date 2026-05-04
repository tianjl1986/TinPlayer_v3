import SwiftUI

struct LyricsView: View {
    @ObservedObject var player = MusicPlayer.shared
    @Binding var showLyrics: Bool
    @Environment(\.colorScheme) var scheme // 🚀 监听系统主题并重命名避免冲突
    
    private let paperWidth: CGFloat = UIScreen.main.bounds.width * 0.85
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header (1:1 Design)
            AppHeader(
                title: "LYRICS",
                leftItem: AnyView(
                    Button(action: { showLyrics = false }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            ZStack(alignment: .top) {
                // Background shadow layer for paper
                Color.clear
                
                // 2. The Paper Scroll
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .center, spacing: 32) {
                            Spacer(minLength: 80) // Gap for the roller
                            
                            if player.isSearchingLyrics {
                                VStack(spacing: 16) {
                                    ProgressView()
                                        .tint(DesignTokens.textPrimary)
                                    Text("Searching lyrics...")
                                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                                        .foregroundColor(DesignTokens.textSecondary)
                                }
                                .padding(.top, 100)
                            } else if player.currentTrackLyrics.isEmpty || player.currentTrackLyrics.first?.text == "Lyrics not found online" {
                                VStack(spacing: 20) {
                                    Text("Lyrics not found")
                                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                                        .foregroundColor(DesignTokens.textSecondary.opacity(0.5))
                                    
                                    Button(action: {
                                        Task {
                                            await player.manualSearchLyrics()
                                        }
                                    }) {
                                        Text("RETRY SEARCH")
                                            .font(.system(size: 12, weight: .black))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(DesignTokens.surfaceSecondary)
                                            .cornerRadius(6)
                                            .foregroundColor(DesignTokens.textPrimary)
                                            .skeuoRaised(cornerRadius: 6)
                                    }
                                }
                                .padding(.top, 100)
                            } else {
                                ForEach(Array(player.currentTrackLyrics.enumerated()), id: \.offset) { index, line in
                                    Text(line.text)
                                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                                        .foregroundColor(index == player.currentLyricIndex ? DesignTokens.textPrimary : DesignTokens.textSecondary.opacity(0.4))
                                        .multilineTextAlignment(.center)
                                        .id(index)
                                }
                            }
                            
                            Spacer(minLength: 200)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 30)
                    }
                    .onChange(of: player.currentLyricIndex) { newIndex in
                        withAnimation(.spring()) {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
                .frame(width: paperWidth)
                .background(DesignTokens.surfaceMain)
                .cornerRadius(4)
                .skeuoRaised(cornerRadius: 4)
                .offset(y: 35)
                
                // 3. The Roller Assembly (1:1 Design)
                ZStack {
                    // 底层：全宽黑色滚筒 - 使用官方切片
                    Image(scheme == .dark ? "roller_dark" : "roller_light")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width, height: 35)
                    
                    // 顶层：悬浮旋钮 - 使用官方切片
                    HStack {
                        // 左旋钮
                        Image(scheme == .dark ? "knob_dark" : "knob_light")
                            .resizable()
                            .frame(width: 25, height: 45)
                        
                        Spacer()
                        
                        // 右旋钮
                        Image(scheme == .dark ? "knob_dark" : "knob_light")
                            .resizable()
                            .frame(width: 25, height: 45)
                    }
                    .padding(.horizontal, 5)
                    .frame(width: UIScreen.main.bounds.width)
                }
                .offset(y: 0)
                .shadow(color: Color.black.opacity(scheme == .dark ? 0.5 : 0.3), radius: 10, x: 0, y: 5)
                .zIndex(10)
            }
            .padding(.bottom, 20)
            
            // 4. Progress Bar & Controls (1:1 Design)
            VStack(spacing: 24) {
                HStack(spacing: 12) {
                    Text(formatDuration(player.currentTime))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(DesignTokens.textSecondary)
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: (UIScreen.main.bounds.width - 150) * CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)), height: 6)
                    }
                    
                    Text(formatDuration(player.duration))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(DesignTokens.textSecondary)
                }
                .padding(.horizontal, 32)
                
                BottomControlsView(showLyrics: $showLyrics)
                    .padding(.bottom, 30) // Adjusted bottom padding
            }
            .padding(.top, 50) // Shifted down by 30px from 20px
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
