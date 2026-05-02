import SwiftUI

struct LibraryGridView: View {
    @EnvironmentObject var libraryService: MusicLibraryService
    @EnvironmentObject var musicPlayer: MusicPlayer
    @ObservedObject var themeManager = ThemeManager.shared
    @State private var expandedAlbumId: UUID? = nil
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                AppColors.background.edgesIgnoringSafeArea(.all)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerView
                        ForEach(libraryService.albums) { album in
                            NavigationLink(destination: AlbumDetailView(album: album)) {
                                AlbumRowHeader(album: album, isExpanded: false)
                            }
                        }
                        Spacer(minLength: 100)
                    }
                }
                
                MiniPlayerView()
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text(LocalizationManager.shared.t("MY COLLECTION"))
                .font(.system(size: 24, weight: .black))
                .foregroundColor(AppColors.textPrimary)
                .tracking(2)
            Spacer()
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(AppColors.textPrimary)
                    .font(.title2)
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 24)
    }
}

struct AlbumRowHeader: View {
    let album: Album
    let isExpanded: Bool
    var body: some View {
        HStack(spacing: 16) {
            if let image = album.coverImage {
                Image(uiImage: image).resizable().frame(width: 54, height: 54).cornerRadius(6)
            } else {
                Color.gray.opacity(0.3).frame(width: 54, height: 54).cornerRadius(6)
            }
            Text("\(album.artist) - \(album.title)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(isExpanded ? AppColors.textPrimary.opacity(0.05) : Color.clear)
    }
}

struct TrackExpansionView: View {
    let album: Album
    @EnvironmentObject var musicPlayer: MusicPlayer
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(album.tracks.enumerated()), id: \.element.id) { index, track in
                HStack {
                    Text("\(index + 1)").foregroundColor(AppColors.textSecondary).frame(width: 30, alignment: .leading)
                    Text(track.title).foregroundColor(AppColors.textPrimary).font(.system(size: 15))
                    Spacer()
                    Text(track.duration).foregroundColor(AppColors.textSecondary).font(.system(size: 12))
                }
                .padding(.leading, 65).padding(.trailing, 20).padding(.vertical, 12)
                .contentShape(Rectangle())
                .onTapGesture { musicPlayer.playTrack(track, in: album.tracks) }
                Divider().background(AppColors.separator).padding(.leading, 65)
            }
        }
        .background(AppColors.textPrimary.opacity(0.02))
    }
}
