import SwiftUI

struct LyricsView: View {
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(
                title: "LYRICS",
                leftItem: AnyView(Color.clear.frame(width: 40)),
                rightItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(10)
                            .skeuoRaised(cornerRadius: 10)
                    }
                )
            )
            
            if player.isSearchingLyrics {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Searching for lyrics...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxHeight: .infinity)
            } else if player.currentTrackLyrics.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "quote.bubble")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.textSecondary.opacity(0.3))
                    Text("No lyrics found for this track")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Button(action: {
                        Task { await player.manualSearchLyrics() }
                    }) {
                        Text("Retry Search")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .skeuoRaised(cornerRadius: 12)
                    }
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            Spacer(minLength: 100)
                            
                            ForEach(Array(player.currentTrackLyrics.enumerated()), id: \.offset) { index, line in
                                Text(line.text)
                                    .font(.system(size: index == player.currentLyricIndex ? 24 : 18, weight: .black))
                                    .foregroundColor(index == player.currentLyricIndex ? AppColors.textActive : AppColors.textSecondary.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                                    .id(index)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: player.currentLyricIndex)
                            }
                            
                            Spacer(minLength: 200)
                        }
                    }
                    .onChange(of: player.currentLyricIndex) { newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex, anchor: .center)
                        }
                    }
                }
            }
            
            // Bottom Knob (Volume/Progress representation)
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    Image("knob") // Using provided asset
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(Double(player.currentTime / (player.duration > 0 ? player.duration : 1)) * 270 - 135))
                        .skeuoRaised(cornerRadius: 40)
                    
                    Text("CONTROL")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
            }
            .padding(.bottom, 40)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
