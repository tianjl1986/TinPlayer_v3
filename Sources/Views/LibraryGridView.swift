import SwiftUI

struct LibraryGridView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var player = MusicPlayer.shared
    @State private var isShelfView = true 
    
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
                            AlbumCard(track: track)
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
        let groups = Dictionary(grouping: libraryService.tracks, by: { $0.artist }) // Grouping by artist for shelf logic
        return groups.map { (key, tracks) in
            GroupedAlbum(id: key, title: key, subtitle: "Artist", tracks: tracks)
        }.sorted { $0.title < $1.title }
    }
}

struct GroupedAlbum: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let tracks: [Track]
}

struct ShelfRow: View {
    let item: GroupedAlbum
    @Binding var expandedId: String?
    @StateObject var player = MusicPlayer.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(item.tracks.count)首曲目")
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
            .background(Color.white.opacity(0.001))
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expandedId = (expandedId == item.id) ? nil : item.id
                }
            }
            
            if expandedId == item.id {
                VStack(spacing: 0) {
                    ForEach(item.tracks) { track in
                        Button(action: {
                            player.play(track: track)
                        }) {
                            HStack {
                                Text(track.title)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Text(track.duration)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                            .background(Color.black.opacity(0.02))
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider().padding(.leading, 24).opacity(0.1)
                    }
                }
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
    }
}

struct AlbumCard: View {
    let track: Track
    @StateObject var player = MusicPlayer.shared
    
    var body: some View {
        Button(action: { player.play(track: track) }) {
            VStack(alignment: .leading, spacing: 12) {
                Rectangle().fill(Color.gray.opacity(0.1))
                    .frame(width: (UIScreen.main.bounds.width - 60) / 2, height: (UIScreen.main.bounds.width - 60) / 2)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.title).font(.system(size: 15, weight: .black)).foregroundColor(AppColors.textPrimary).lineLimit(1)
                    Text(track.artist).font(.system(size: 13, weight: .bold)).foregroundColor(AppColors.textSecondary).lineLimit(1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
