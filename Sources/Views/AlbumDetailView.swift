import SwiftUI

struct AlbumDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    
    let album: Album
    
    // 过滤出属于该专辑的曲目
    private var albumTracks: [LocalTrack] {
        libraryService.tracks.filter { $0.album == album.title }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(
                title: "ALBUMS".localized,
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("<")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                )
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    // Album Cover & Info
                    VStack(spacing: 16) {
                        // 专辑封面
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.background)
                                .frame(width: 200, height: 200)
                                .skeuoRaised(cornerRadius: 12)
                            
                            if let firstTrack = albumTracks.first, let artwork = firstTrack.artwork {
                                Image(uiImage: artwork)
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
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(album.artist)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.top, 24)
                    
                    // Action Buttons
                    HStack(spacing: 24) {
                        Button(action: {
                            if let first = albumTracks.first {
                                player.play(track: first, in: albumTracks)
                            }
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Play All")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 140, height: 44)
                            .background(AppColors.background)
                            .skeuoRaised(cornerRadius: 22)
                        }
                        
                        Button(action: {
                            if let random = albumTracks.randomElement() {
                                player.playbackMode = .shuffle
                                player.play(track: random, in: albumTracks)
                            }
                        }) {
                            HStack {
                                Image(systemName: "shuffle")
                                Text("Shuffle")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 140, height: 44)
                            .background(AppColors.background)
                            .skeuoRaised(cornerRadius: 22)
                        }
                    }
                    
                    // Track List
                    VStack(spacing: 0) {
                        ForEach(Array(albumTracks.enumerated()), id: \.element.id) { index, track in
                            Button(action: {
                                player.play(track: track, in: albumTracks)
                            }) {
                                HStack(spacing: 16) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(AppColors.textSecondary)
                                        .frame(width: 24, alignment: .leading)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(track.title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(player.currentTrack?.persistentID == track.persistentID ? .blue : AppColors.textPrimary)
                                        
                                        Text(formatDuration(track.duration))
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if player.currentTrack?.persistentID == track.persistentID && player.isPlaying {
                                        Image(systemName: "waveform")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .frame(height: 60)
                                .background(AppColors.background)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if index < albumTracks.count - 1 {
                                Divider().padding(.leading, 64)
                            }
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
