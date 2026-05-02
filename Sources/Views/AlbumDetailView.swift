import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var player = MusicPlayer.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(
                title: "ALBUM DETAIL",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                ),
                rightItem: AnyView(Color.clear.frame(width: 40))
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    // Album Info Section
                    HStack(alignment: .top, spacing: 24) {
                        if let cover = album.coverImage {
                            Image(uiImage: cover)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 140, height: 140)
                                .cornerRadius(12)
                                .skeuoRaised(cornerRadius: 12)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 140, height: 140)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(album.title)
                                .font(.system(size: 24, weight: .black))
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(album.artist)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary)
                                Text("\(album.releaseYear) · \(album.trackCount)首曲目")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.7))
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
                    // Track List
                    VStack(spacing: 0) {
                        ForEach(Array(album.tracks.enumerated()), id: \.offset) { index, track in
                            Button(action: {
                                player.playTrack(track, in: album.tracks)
                            }) {
                                HStack(spacing: 20) {
                                    Text(String(format: "%02d", index + 1))
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(AppColors.textSecondary)
                                        .frame(width: 24)
                                    
                                    Text(track.title)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(player.currentTrack?.id == track.id ? AppColors.textActive : AppColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text(track.duration)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(player.currentTrack?.id == track.id ? Color.black.opacity(0.05) : Color.clear)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.leading, 68).opacity(0.05)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.vertical, 20)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
