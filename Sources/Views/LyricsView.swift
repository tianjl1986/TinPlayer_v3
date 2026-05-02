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
                    // Main Roller Body (Figma 9893:14780)
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
                    
                    // Roller Knobs (Figma 9960:15442/3)
                    HStack {
                        metalKnob
                        Spacer()
                        metalKnob
                    }
                    .padding(.horizontal, -20)
                }
                .padding(.horizontal, 24)
                .zIndex(10)
                .offset(y: 12)
                
                // 🚀 3. Paper Sheet (Figma 9893:14779)
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(themeManager.currentTheme == .light ? Color(hex: "#F4F4F0") : Color(hex: "#121212"))
                        .skeuoRaised(radius: 8, offset: 4)
                        .overlay(
                            // Paper Grid Pattern
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
                
                // 🚀 4. Progress Bar (Figma 9956:15426)
                HStack(spacing: 16) {
                    Text(formatDuration(player.currentTime))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(themeManager.textSecondary)
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(themeManager.currentTheme == .light ? Color(hex: "#E5E5E5") : Color(hex: "#222222"))
                            .frame(height: 8)
                            .skeuoSunken(radius: 8, offset: 4)
                        
                        Capsule()
                            .fill(themeManager.currentTheme == .light ? Color(hex: "#404040") : Color.orange)
                            .frame(width: max(0, (UIScreen.main.bounds.width - 160) * (player.duration > 0 ? player.currentTime / player.duration : 0)), height: 8)
                    }
                    
                    Text(formatDuration(player.duration))
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(themeManager.textSecondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 32)
                
                // 🚀 5. Playback Controls (Figma 9956:15430)
                HStack(spacing: 0) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("LRC")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(themeManager.textSecondary)
                            .frame(width: 40, height: 40)
                            .skeuoRaised(cornerRadius: 20)
                    }
                    Spacer()
                    Button(action: { player.skipPrevious() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(themeManager.textPrimary)
                            .frame(width: 56, height: 56)
                            .skeuoRaised(cornerRadius: 28)
                    }
                    Spacer()
                    Button(action: { player.togglePlayPause() }) {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.textPrimary)
                            .frame(width: 72, height: 72)
                            .skeuoRaised(cornerRadius: 36)
                    }
                    Spacer()
                    Button(action: { player.skipNext() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(themeManager.textPrimary)
                            .frame(width: 56, height: 56)
                            .skeuoRaised(cornerRadius: 28)
                    }
                    Spacer()
                    Button(action: { player.togglePlaybackMode() }) {
                        Text("Q")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(themeManager.textSecondary)
                            .frame(width: 40, height: 40)
                            .skeuoRaised(cornerRadius: 20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
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
            .frame(width: 60, height: 60)
            .overlay(
                Circle()
                    .stroke(
                        AngularGradient(colors: [.white, .black.opacity(0.1), .white], center: .center),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 12, x: 4, y: 8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
