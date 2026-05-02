import SwiftUI

struct AlbumDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var musicPlayer: MusicPlayer
    @ObservedObject var themeManager = ThemeManager.shared
    
    let album: Album
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                AppHeader(
                    title: "ALBUM".localized,
                    leftItem: AnyView(
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 40, height: 40)
                        }
                    )
                )
                
                ScrollView {
                    VStack(spacing: 32) {
                        // 🚀 Album Header (Figma 9931:15076)
                        VStack(spacing: 24) {
                            if let image = album.coverImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 160, height: 160)
                                    .cornerRadius(8)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppColors.textPrimary.opacity(0.1))
                                    .frame(width: 160, height: 160)
                            }
                            
                            VStack(spacing: 8) {
                                Text(album.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text("\(album.artist) • \(album.releaseYear)")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            HStack(spacing: 16) {
                                Button(action: {
                                    if let first = album.tracks.first {
                                        musicPlayer.playTrack(first, in: album.tracks)
                                    }
                                }) {
                                    Text("Play All")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(width: 99, height: 41)
                                        .skeuoRaised(cornerRadius: 24)
                                }
                                
                                Button(action: {
                                    // Shuffle and play
                                    let shuffled = album.tracks.shuffled()
                                    if let first = shuffled.first {
                                        musicPlayer.playTrack(first, in: shuffled)
                                    }
                                }) {
                                    Text("Shuffle")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(width: 98, height: 41)
                                        .skeuoRaised(cornerRadius: 24)
                                }
                            }
                        }
                        .padding(.top, 24)
                        
                        // 🚀 Track List (Figma 9931:15081)
                        VStack(spacing: 0) {
                            ForEach(Array(album.tracks.enumerated()), id: \.element.id) { index, track in
                                Button(action: {
                                    musicPlayer.playTrack(track, in: album.tracks)
                                }) {
                                    HStack(spacing: 16) {
                                        Text(String(format: "%02d", index + 1))
                                            .font(.system(size: 14, design: .monospaced))
                                            .foregroundColor(AppColors.textSecondary)
                                            .frame(width: 30)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(track.title)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(musicPlayer.currentTrack?.id == track.id ? .orange : AppColors.textPrimary)
                                            Text(track.artist)
                                                .font(.system(size: 13))
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(track.duration)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 20)
                                    .background(musicPlayer.currentTrack?.id == track.id ? AppColors.background.opacity(0.5) : Color.clear)
                                }
                                
                                if index < album.tracks.count - 1 {
                                    Divider().padding(.leading, 66).background(AppColors.separator)
                                }
                            }
                        }
                        .background(AppColors.background)
                        .skeuoSunken(cornerRadius: 16)
                        .padding(20)
                        
                        Spacer(minLength: 120) // 🚀 修复“掉下去”的关键：用动态 Spacer 代替硬编码 Padding
                    }
                }
            }
            
            MiniPlayerView()
                .padding(.bottom, 10)
        }
        .navigationBarHidden(true)
    }
}
