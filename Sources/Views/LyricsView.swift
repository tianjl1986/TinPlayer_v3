import SwiftUI

struct LyricsView: View {
    @ObservedObject var player = MusicPlayer.shared
    @Binding var showLyrics: Bool
    
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
                            
                            if player.currentTrackLyrics.isEmpty {
                                Text("No lyrics available")
                                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                                    .foregroundColor(DesignTokens.textSecondary.opacity(0.5))
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
                .background(DesignTokens.surfaceMain) // Use surfaceMain which is dark in Dark Mode
                .cornerRadius(4)
                .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 30) // Heavier shadow for dark mode
                .offset(y: 35)
                
                // 3. The Roller Assembly (1:1 Design)
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // Left Chrome Cap
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hexString: "#E0E0E0"), Color(hexString: "#F5F5F5"), Color(hexString: "#BDBDBD")]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 25, height: 45)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 1))
                        
                        // Main Black Bar
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hexString: "#1A1A1A"), Color(hexString: "#333333"), Color(hexString: "#111111")]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 35)
                        
                        // Right Chrome Cap
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hexString: "#E0E0E0"), Color(hexString: "#F5F5F5"), Color(hexString: "#BDBDBD")]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 25, height: 45)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 1))
                    }
                    .padding(.horizontal, 10)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .zIndex(10)
            }
            .frame(maxHeight: .infinity)
            
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
                    .padding(.bottom, 40)
            }
            .padding(.top, 20)
        }
        .background(DesignTokens.surfaceSecondary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
