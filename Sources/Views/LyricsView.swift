import SwiftUI

struct LyricsView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    // Figma 1:1 几何参数
    private let rollerHeight: CGFloat = 50
    private let knobSize: CGSize = CGSize(width: 64, height: 64)
    private let paperWidth: CGFloat = 340
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header - Standardized
            AppHeader(
                title: "LYRICS",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            
            // 2. Typewriter Area
            ZStack(alignment: .top) {
                // Paper - 9885:14798
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
                            
                            Spacer(minLength: 400) // Ensure enough scroll space at bottom
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
                .offset(y: 35) // Align with roller
                .zIndex(0)
                
                // Roller Assembly - Use GeometryReader to avoid squeezing
                GeometryReader { rollerGeo in
                    HStack(spacing: 0) {
                        Image("knob_light")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: knobSize.width, height: knobSize.height)
                        
                        Image("roller_light")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: rollerGeo.size.width - 128, height: rollerHeight)
                            .clipped()
                        
                        Image("knob_light")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: knobSize.width, height: knobSize.height)
                    }
                }
                .frame(height: 64)
                .padding(.horizontal, 10)
                .zIndex(1)
            }
            .frame(maxHeight: .infinity)
            
            // 3. Spacing and Controls - Matches NowPlayingView
            VStack(spacing: 24) {
                // Progress Bar with Times
                VStack(spacing: 12) {
                    HStack {
                        Text(formatDuration(player.currentTime))
                        Spacer()
                        Text(formatDuration(player.duration))
                    }
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(DesignTokens.textSecondary)
                    
                    progressBar
                }
                .padding(.horizontal, 48)
                
                BottomControlsView()
                    .padding(.bottom, 40)
            }
            .padding(.top, 24)
            .background(DesignTokens.surfaceMain)
        }
        .background(DesignTokens.surfaceMain.ignoresSafeArea())
        .navigationBarHidden(true)
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
