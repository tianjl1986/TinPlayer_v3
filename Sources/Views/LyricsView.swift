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
                // Paper - 9885:14798
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 32) {
                            Spacer(minLength: 120)
                            
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
                            
                            Spacer(minLength: 240)
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
                .frame(width: 335) // Figma paper width
                .background(Color.white)
                .skeuoRaised(cornerRadius: 4)
                .offset(y: 20)
                .zIndex(0)
                
                // Roller Assembly - Static
                HStack(spacing: 0) {
                    Image("knob_light")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .offset(x: -16)
                    
                    Image("roller_light")
                        .resizable()
                        .frame(height: 48)
                    
                    Image("knob_light")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .offset(x: 16)
                }
                .padding(.horizontal, 10)
                .zIndex(1)
            }
            .frame(maxHeight: .infinity)
            
            // 3. Spacing and Controls - Standardized Gaps
            VStack(spacing: 32) {
                // Progress Bar - Sunken
                VStack(spacing: 12) {
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
                .padding(.horizontal, 48)
                
                BottomControlsView()
                    .padding(.bottom, 32)
            }
            .padding(.top, 32)
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
        HStack {
            Text(isCurrent ? String(text.prefix(revealedCharacters)) : text)
                .font(.system(size: 16, weight: isCurrent ? .black : .bold, design: .monospaced))
                .foregroundColor(isCurrent ? DesignTokens.textPrimary : DesignTokens.textSecondary.opacity(0.4))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            if isCurrent {
                revealedCharacters = 0
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
        // Reset timer or just use a task
        Task {
            for i in 0...text.count {
                if !isCurrent { break }
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
                await MainActor.run {
                    revealedCharacters = i
                }
            }
        }
    }
}
