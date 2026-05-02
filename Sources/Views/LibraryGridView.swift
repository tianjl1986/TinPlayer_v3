import SwiftUI

struct LibraryGridView: View {
    @EnvironmentObject var libraryService: MusicLibraryService
    @EnvironmentObject var musicPlayer: MusicPlayer
    @State private var expandedAlbumId: UUID? = nil
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerView
                    
                    ForEach(libraryService.albums) { album in
                        VStack(spacing: 0) {
                            AlbumRowHeader(album: album, isExpanded: expandedAlbumId == album.id)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        expandedAlbumId = (expandedAlbumId == album.id) ? nil : album.id
                                    }
                                }
                            
                            if expandedAlbumId == album.id {
                                TrackExpansionView(album: album)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .move(edge: .top)),
                                        removal: .opacity
                                    ))
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("MY COLLECTION")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(.white)
                .tracking(2)
            Spacer()
            // 🚀 这里点击去设置
            NavigationLink(destination: SettingsView()) {
                Image(systemName: "gearshape.fill").foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
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
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            Image(systemName: "chevron.right")
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14
