import SwiftUI

struct LyricsView: View {
    @ObservedObject var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            themeManager.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 🚀 1. Top Bar (Figma 9893:14778)
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(themeManager.textPrimary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    Spacer()
                    Text(localizationManager.t("LYRICS"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeManager.textPrimary)
                    Spacer()
                    Button(action: { /* Options */ }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(themeManager.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // 🚀 2. Typewriter Platen Roller (Printer Mechanical Assembly)
                ZStack {
                    // Main Roller Body (Figma 10411:3203)
                    Capsule()
                        .fill(
                            LinearGradient(colors: [
                                Color(hex: "#0d0d0d"), 
                                Color(hex: "#404040"), 
                                Color(hex: "#1a1a1a"), 
                                Color(hex: "#404040"), 
                                Color(hex: "#0d0d0d")
                            ], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(height: 32)
                        .overlay(
                            Capsule().stroke(Color.black.opacity(0.8), lineWidth: 1)
                        )
                    
                    // Roller Knobs (Restored with proper alignment - Fix White Outline)
                    HStack {
                        metalKnob
                        Spacer()
                        metalKnob
                    }
                    .padding(.horizontal, -12) // Overlap slightly per mechanical design
                }
                .padding(.horizontal, 24)
                .zIndex(10)
                .offset(y: 16)
                
                // 🚀 3. Paper Sheet (Figma 9893:14779)
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(themeManager.currentTheme == .light ? Color(hex: "#F4F4F0") : Color(hex: "#121212")) // 🚀 Figma 10411:3210
                        .skeuoRaised(radius: 8, offset: 4)
                        .overlay(
                            // 🚀 Paper Grid Pattern (High Fidelity restoration)
                            GeometryReader { geo in
                                Path { path in
                                    let spacing: CGFloat = 16
                                    let lines = Int(geo.size.height / spacing)
                                    for i in 0...lines {
                                        let y = CGFloat(i) * spacing
                                        path.move(to: CGPoint(x: 0, y: y))
                                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                                    }
                                }
                                .stroke(themeManager.currentTheme == .light ? Color.black.opacity(0.04) : Color.white.opacity(0.04), lineWidth: 0.5)
                            }
                        )
                    
                    VStack(spacing: 0) {
                        // Current Track Info on Paper
                        VStack(spacing: 8) {
                            Text(player.currentTrack?.title ?? "---")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(themeManager.textPrimary)
                            Text(player.currentTrack?.artist ?? "---")
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(themeManager.textSecondary)
                        }
                        .padding(.top, 60)
                        
                        // Lyrics Content
                        ScrollViewReader { proxy in
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 24) {
                                    Spacer(minLength: 40)
                                    if !player.currentTrackLyrics.isEmpty {
                                        ForEach(player.currentTrackLyrics.indices, id: \.self) { index in
                                            Text(player.currentTrackLyrics[index].text)
                                                .font(.custom("Courier-Bold", size: 20))
                                                .foregroundColor(index == player.currentLyricIndex ? themeManager.textPrimary : themeManager.textSecondary.opacity(0.4))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 32)
                                                .scaleEffect(index == player.currentLyricIndex ? 1.05 : 1.0)
                                                .id(index)
                                        }
                                    } else {
                                        noLyricsView
                                    }
                                    Spacer(minLength: 200)
                                }
                            }
                            .onChange(of: player.currentLyricIndex) { newIndex in
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    proxy.scrollTo(newIndex, anchor: .center)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // 🚀 4. Bottom Controls (Standardized)
                VStack(spacing: 24) {
                    // Mini Progress Bar on Bottom
                    VStack(spacing: 8) {
                        HStack {
                            Text(formatDuration(player.currentTime))
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(themeManager.textSecondary)
                            Spacer()
                            Text(formatDuration(player.duration))
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(themeManager.textSecondary)
                        }
                        .padding(.horizontal, 24)
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(themeManager.background)
                                .frame(height: 6)
                                .skeuoSunken(radius: 2, offset: 1)
                            
                            Capsule()
                                .fill(Color.orange)
                                .frame(width: max(0, (UIScreen.main.bounds.width - 48) * (player.duration > 0 ? player.currentTime / player.duration : 0)), height: 6)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Control Row
                    HStack(spacing: 0) {
                        playbackButton(icon: "backward.fill", size: 54, action: { player.skipPrevious() })
                        Spacer()
                        playbackButton(icon: player.isPlaying ? "pause.fill" : "play.fill", size: 72, action: { player.togglePlayPause() })
                        Spacer()
                        playbackButton(icon: "forward.fill", size: 54, action: { player.skipNext() })
                    }
                    .padding(.horizontal, 48)
                }
                .padding(.vertical, 32)
                .background(themeManager.background)
            }
        }
    }
    
    private func playbackButton(icon: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(themeManager.background)
                    .skeuoRaised(radius: 8, offset: 4)
                Image(systemName: icon)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(themeManager.textPrimary)
            }
            .frame(width: size, height: size)
        }
    }
    
    private var noLyricsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(themeManager.textSecondary.opacity(0.3))
            Text(localizationManager.t("NO LYRICS FOUND"))
                .font(.custom("Courier", size: 16))
                .foregroundColor(themeManager.textSecondary)
        }
        .padding(.top, 100)
    }
    
    private var metalKnob: some View {
        Circle()
            .fill(
                LinearGradient(colors: [
                    Color(hex: "#999999"), 
                    Color(hex: "#ffffff"), 
                    Color(hex: "#cccccc"), 
                    Color(hex: "#ffffff"), 
                    Color(hex: "#999999")
                ], startPoint: .top, endPoint: .bottom)
            )
            .frame(width: 44, height: 44)
            .overlay(
                Circle()
                    .stroke(
                        AngularGradient(colors: [.white, .black.opacity(0.1), .white], center: .center),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 2)
    }
}
