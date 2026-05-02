import SwiftUI

struct LyricsView: View {
    @ObservedObject var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 🚀 1. Top Bar
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                    Text("LYRICS".localized)
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Button(action: { /* Options */ }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // 🚀 2. Typewriter Platen Roller (Figma 9935:15203)
                ZStack {
                    Capsule()
                        .fill(
                            LinearGradient(colors: [
                                Color(hex: "#0d0d0d"), 
                                Color(hex: "#333333"), 
                                Color(hex: "#1a1a1a"), 
                                Color(hex: "#333333"), 
                                Color(hex: "#0d0d0d")
                            ], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(height: 36)
                        .skeuoRaised(cornerRadius: 18)
                    
                    // Roller Knobs
                    HStack {
                        metalKnob
                        Spacer()
                        metalKnob
                    }
                    .padding(.horizontal, -12)
                }
                .padding(.horizontal, 32)
                .zIndex(10)
                
                // 🚀 2. Typewriter Roller (滚筒) - Figma 9935:15194
                ZStack {
                    Capsule()
                        .fill(LinearGradient(colors: [Color(hex: "#1a1a1a"), Color(hex: "#333333"), Color(hex: "#000000")], startPoint: .top, endPoint: .bottom))
                        .frame(height: 44)
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    // 滚筒上的金属旋钮 (Knobs)
                    HStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "#888888"), Color(hex: "#444444")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                            .skeuoRaised(cornerRadius: 20)
                            .offset(x: -20)
                        Spacer()
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "#888888"), Color(hex: "#444444")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 40, height: 40)
                            .skeuoRaised(cornerRadius: 20)
                            .offset(x: 20)
                    }
                }
                .zIndex(2)
                .offset(y: -40)
                
                // 🚀 3. Paper Sheet (Figma 9935:15197)
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "#fafafa")) // Ivory White
                        .skeuoRaised(cornerRadius: 2)
                        .overlay(
                            // 🚀 增加纸张纹理感
                            VStack(spacing: 2) {
                                ForEach(0..<100) { _ in
                                    Divider().background(Color.black.opacity(0.02))
                                }
                            }
                        )
                    
                    VStack(spacing: 0) {
                        // Current Track Info
                        VStack(spacing: 8) {
                            Text(player.currentTrack?.title ?? "---")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(hex: "#1a1a1a"))
                            Text(player.currentTrack?.artist ?? "---")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(hex: "#666666"))
                        }
                        .padding(.top, 50)
                        
                        // Lyrics Content
                        ScrollViewReader { proxy in
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 28) {
                                    Spacer(minLength: 60)
                                    if !player.currentTrackLyrics.isEmpty {
                                        ForEach(player.currentTrackLyrics.indices, id: \.self) { index in
                                            Text(player.currentTrackLyrics[index].text)
                                                .font(.custom("Courier-Bold", size: 20))
                                                .foregroundColor(index == player.currentLyricIndex ? Color(hex: "#000000") : Color(hex: "#bbbbbb"))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 44)
                                                .scaleEffect(index == player.currentLyricIndex ? 1.05 : 1.0)
                                                .id(index)
                                        }
                                    } else {
                                        VStack(spacing: 24) {
                                            if player.isSearchingLyrics {
                                                ProgressView()
                                                Text("SEARCHING...".localized)
                                                    .font(.custom("Courier", size: 16))
                                                    .foregroundColor(.gray)
                                            } else {
                                                Image(systemName: "text.magnifyingglass")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.gray.opacity(0.3))
                                                
                                                Text("NO LYRICS FOUND".localized)
                                                    .font(.custom("Courier", size: 16))
                                                    .foregroundColor(.gray)
                                                
                                                Button(action: {
                                                    Task {
                                                        await player.manualSearchLyrics()
                                                    }
                                                }) {
                                                    Text("RETRY SEARCH".localized)
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 24)
                                                        .padding(.vertical, 12)
                                                        .background(Color.orange)
                                                        .cornerRadius(20)
                                                        .skeuoRaised(cornerRadius: 20)
                                                }
                                            }
                                        }
                                        .padding(.top, 100)
                                    }
                                    Spacer(minLength: 250)
                                }
                            }
                            .onChange(of: player.currentLyricIndex) { newIndex in
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    proxy.scrollTo(newIndex, anchor: .center)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 28)
                .offset(y: -15)
                
                // 🚀 4. Bottom Controls (Figma 9956:15408)
                VStack(spacing: 32) {
                    // Progress Bar
                    HStack(spacing: 16) {
                        Text(formatDuration(player.currentTime))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: 45)
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppColors.background)
                                .skeuoSunken(cornerRadius: 4)
                                .frame(height: 8)
                            
                            Capsule()
                                .fill(Color(hex: "#404040"))
                                .frame(width: max(0, CGFloat(player.currentTime / (player.duration > 0 ? player.duration : 1)) * 200), height: 8)
                        }
                        
                        Text(formatDuration(player.duration))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: 45)
                    }
                    .padding(.horizontal, 24)
                    
                    // Playback Controls
                    HStack(spacing: 20) {
                        Button(action: { /* Toggle LRC */ }) {
                            Text("LRC")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary)
                                .frame(width: 54, height: 54)
                                .skeuoRaised(cornerRadius: 27)
                        }
                        
                        Spacer()
                        
                        Button(action: { player.skipPrevious() }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "#1a1a1a"))
                                .frame(width: 64, height: 64)
                                .skeuoRaised(cornerRadius: 32)
                        }
                        
                        Button(action: { player.togglePlayPause() }) {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "#1a1a1a"))
                                .frame(width: 80, height: 80)
                                .skeuoRaised(cornerRadius: 40)
                        }
                        
                        Button(action: { player.skipNext() }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "#1a1a1a"))
                                .frame(width: 64, height: 64)
                                .skeuoRaised(cornerRadius: 32)
                        }
                        
                        Spacer()
                        
                        Button(action: { /* Queue */ }) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textSecondary)
                                .frame(width: 54, height: 54)
                                .skeuoRaised(cornerRadius: 27)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .background(AppColors.background)
            }
        }
        .navigationBarHidden(true)
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
            .frame(width: 54, height: 54)
            .skeuoRaised(cornerRadius: 27)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 4)
    }
}
