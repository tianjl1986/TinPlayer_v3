import SwiftUI

struct LibraryGridView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var player = MusicPlayer.shared
    @State private var filterMode: FilterMode = .tracks
    @State private var isShelfView = true 
    @State private var showingPlayer = false
    
    enum FilterMode: String, CaseIterable {
        case tracks = "TRACKS"
        case albums = "ALBUMS"
        case artists = "ARTISTS"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            AppHeader(
                title: isShelfView ? "ALBUMS" : "LIBRARY",
                leftItem: AnyView(
                    Button(action: { /* Back */ }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { isShelfView.toggle() }) {
                        Image(systemName: isShelfView ? "square.grid.2x2.fill" : "list.bullet")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(10)
                            .skeuoRaised(cornerRadius: 10)
                    }
                )
            )
            
            ScrollView(showsIndicators: false) {
                if isShelfView {
                    ShelfView(items: groupedAlbums)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 28) {
                        ForEach(libraryService.tracks) { track in
                            Button(action: {
                                player.play(track: track)
                                showingPlayer = true
                            }) {
                                AlbumCard(title: track.title, artist: track.artist, artwork: track.artwork)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
    
    private var groupedAlbums: [GroupedAlbum] {
        let groups = Dictionary(grouping: libraryService.tracks, by: { $0.album })
        return groups.map { (key, tracks) in
            GroupedAlbum(id: key, title: key, subtitle: tracks.first?.artist ?? "Unknown", artwork: tracks.first?.artwork, tracks: tracks)
        }.sorted { $0.title < $1.title }
    }
}

struct GroupedAlbum: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let artwork: UIImage?
    let tracks: [Track]
}

struct ShelfRow: View {
    let item: GroupedAlbum
    @Binding var expandedId: String?
    @StateObject var player = MusicPlayer.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Row (NO ORANGE BLOCK HERE)
            HStack(spacing: 16) {
                if let artwork = item.artwork {
                    Image(uiImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text(item.subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.textSecondary.opacity(0.5))
                    .rotationEffect(.degrees(expandedId == item.id ? 90 : 0))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.001)) // Make entire area tappable
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    if expandedId == item.id {
                        expandedId = nil
                    } else {
                        expandedId = item.id
                    }
                }
            }
            
            // Expanded Tracks
            if expandedId == item.id {
                VStack(spacing: 0) {
                    ForEach(item.tracks) { track in
                        Button(action: {
                            player.play(track: track)
                        }) {
                            HStack {
                                Text(String(format: "%02d", track.trackNumber))
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(AppColors.textSecondary)
                                    .frame(width: 24, alignment: .leading)
                                
                                Text(track.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Text(String(format: "%d:%02d", Int(track.duration)/60, Int(track.duration)%60))
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                            .background(Color.black.opacity(0.02))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider().padding(.leading, 64).opacity(0.1)
                    }
                }
                .transition(.opacity)
            }
            
            Divider().padding(.horizontal, 20).opacity(0.05)
        }
    }
}

struct ShelfView: View {
    let items: [GroupedAlbum]
    @State private var expandedId: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(items) { item in
                ShelfRow(item: item, expandedId: $expandedId)
            }
        }
        .padding(.top, 10)
    }
}

struct AlbumCard: View {
    let title: String
    let artist: String
    let artwork: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                if let image = artwork {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle().fill(Color.gray.opacity(0.1))
                }
            }
            .frame(width: (UIScreen.main.bounds.width - 60) / 2, height: (UIScreen.main.bounds.width - 60) / 2)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Text(artist)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
        }
    }
}
