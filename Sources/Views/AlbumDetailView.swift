import SwiftUI

struct AlbumDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    let album: Album
    
    var body: some View {
        ZStack(alignment: .bottom) {
            themeManager.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 🚀 App Header (Figma 9930:15071)
                AppHeader(
                    title: localizationManager.t("ALBUM"),
                    leftItem: AnyView(
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                                .frame(width: 44, height: 44)
                        }
                    )
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) { // 🚀 Figma 9931:15075 itemSpacing
                        // 🚀 1. Album Header (Figma 9931:15076)
                        VStack(spacing: 24) {
                            if let image = album.coverImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 160, height: 160)
                                    .cornerRadius(8)
                                    .skeuoRaised(radius: 4, offset: 2)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.textSecondary.opacity(0.1))
                                    .frame(width: 160, height: 160)
                            }
                            
                            VStack(spacing: 8) {
                                Text(album.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(themeManager.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text("\(album.artist) • \(album.releaseYear)")
                                    .font(.system(size: 14))
                                    .foregroundColor(themeManager.textSecondary)
                            }
                            
                            // Action Buttons (Play All / Shuffle)
                            HStack(spacing: 16) {
                                Button(action: {
                                    if let first = album.tracks.first {
                                        player.playTrack(first, in: album.tracks)
                                    }
                                }) {
                                    Text(localizationManager.t("PLAY ALL"))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(themeManager.textPrimary)
                                        .frame(width: 120, height: 44)
                                        .skeuoRaised(cornerRadius: 22)
                                }
                                
                                Button(action: {
                                    let shuffled = album.tracks.shuffled()
                                    if let first = shuffled.first {
                                        player.playTrack(first, in: shuffled)
                                    }
                                }) {
                                    Text(localizationManager.t("SHUFFLE"))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(themeManager.textPrimary)
                                        .frame(width: 120, height: 44)
                                        .skeuoRaised(cornerRadius: 22)
                                }
                            }
                        }
                        .padding(.top, 24)
                        
                        // 🚀 2. Track List (Figma 9931:15081)
                        VStack(spacing: 0) {
                            ForEach(Array(album.tracks.enumerated()), id: \.element.id) { index, track in
                                Button(action: {
                                    player.playTrack(track, in: album.tracks)
                                }) {
                                    HStack(spacing: 16) {
                                        Text(String(format: "%02d", index + 1))
                                            .font(.system(size: 14, design: .monospaced))
                                            .foregroundColor(themeManager.textSecondary)
                                            .frame(width: 30)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(track.title)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(player.currentTrack?.id == track.id ? .orange : themeManager.textPrimary)
                                            Text(track.artist)
                                                .font(.system(size: 13))
                                                .foregroundColor(themeManager.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(track.duration)
                                            .font(.system(size: 14))
                                            .foregroundColor(themeManager.textSecondary)
                                    }
                                    .padding(.vertical, 16) // 🚀 Figma 9931:15087 padding
                                    .padding(.horizontal, 20)
                                    .contentShape(Rectangle())
                                    .background(player.currentTrack?.id == track.id ? Color.orange.opacity(0.1) : Color.clear)
                                }
                                
                                if index < album.tracks.count - 1 {
                                    Divider()
                                        .padding(.leading, 66)
                                        .opacity(0.1)
                                }
                            }
                        }
                        .background(themeManager.currentTheme == .light ? Color.white : Color(hex: "#1A1A1A"))
                        .cornerRadius(16)
                        .skeuoSunken(radius: 4, offset: 2)
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 140)
                    }
                    .padding(.bottom, 60)
                }
            }
            
            // Mini Player Overlaid at bottom
            MiniPlayerView()
                .padding(.bottom, 10)
                .zIndex(100) // Ensure it's on top but check if it blocks
        }
        .navigationBarHidden(true)
    }
}
