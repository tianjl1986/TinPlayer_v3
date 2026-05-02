import SwiftUI

struct AlbumDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var player = MusicPlayer.shared
    @ObservedObject private var libraryService = MusicLibraryService.shared
    
    let album: Album
    
    private var albumTracks: [Track] {
        album.tracks
    }
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                title: "ALBUMS",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("<")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                    }
                )
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 200, height: 200)
                            
                            if let image = album.coverImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 180, height: 180)
                                    .cornerRadius(8)
                            }
                        }
                        
                        VStack(spacing: 4) {
                            Text(album.title)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(album.artist)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
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
                            .foregroundColor(.white)
                            .frame(width: 140, height: 44)
                            .background(Color.blue)
                            .cornerRadius(22)
                        }
                    }
                    
                    VStack(spacing: 0) {
                        ForEach(Array(albumTracks.enumerated()), id: \.element.id) { index, track in
                            Button(action: {
                                player.playTrack(track, in: albumTracks)
                            }) {
                                HStack(spacing: 16) {
                                    Text("\(index + 1)")
                                        .foregroundColor(.gray)
                                        .frame(width: 24, alignment: .leading)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(track.title)
                                            .foregroundColor(player.currentTrack?.id == track.id ? .blue : .white)
                                        Text(track.duration).font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                .frame(height: 60)
                            }
                            Divider().padding(.leading, 64)
                        }
                    }
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}
