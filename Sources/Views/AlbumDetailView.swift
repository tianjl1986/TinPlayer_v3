import SwiftUI

struct AlbumDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var player = MusicPlayer.shared
    @ObservedObject private var libraryService = MusicLibraryService.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    
    let album: Album
    
    private var albumTracks: [Track] {
        album.tracks
    }
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: "ALBUMS".localized,
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                )
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.background)
                                .skeuoSunken(cornerRadius: 12)
                                .frame(width: 200, height: 200)
                            
                            if let image = album.coverImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 180, height: 180)
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "music.note")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text(album.title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text(album.artist)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.top, 24)
                    
                    HStack(spacing: 24) {
                        Button(action: {
                            if let first = albumTracks.first {
                                player.playTrack(first, in: albumTracks)
                            }
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Play All")
                            }
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 140, height: 44)
                            .skeuoRaised(cornerRadius: 22)
                        }
                    }
                    
                    VStack(spacing: 0) {
                        ForEach(Array(albumTracks.enumerated()), id: \.element.id) { index, track in
                            Button(action: {
                                player.playTrack(track, in: albumTracks)
                            }) {
                                HStack(spacing: 16) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, design: .monospaced))
                                        .foregroundColor(AppColors.textSecondary)
                                        .frame(width: 30, alignment: .leading)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(track.title)
                                            .font(.system(size: 16))
                                            .foregroundColor(player.currentTrack?.id == track.id ? .blue : AppColors.textPrimary)
                                        Text(track.duration)
                                            .font(.system(size: 12))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                .frame(height: 64)
                                .contentShape(Rectangle())
                            }
                            Divider().background(AppColors.separator).padding(.leading, 70)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
