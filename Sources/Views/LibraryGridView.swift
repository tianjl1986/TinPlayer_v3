import SwiftUI

// MARK: - 音乐库页 (结构拆解版 - 最终修正)
struct LibraryGridView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var player = MusicPlayer.shared
    @State private var showSettings = false
    @State private var showPlayer = false
    @State private var isShelfMode = false
    @State private var expandedAlbum: String? = nil

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                contentView
            }
            .background(AppColors.background)
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $showSettings) { SettingsView() }
            .fullScreenCover(isPresented: $showPlayer) { NowPlayingView() }
            .onAppear {
                if libraryService.tracks.isEmpty {
                    libraryService.requestPermissionAndScan()
                }
            }
        }
    }

    private var headerView: some View {
        AppHeader(
            title: "MY COLLECTION".localized,
            leftItem: AnyView(
                Button(action: { showSettings = true }) {
                    Text("<")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 40, height: 40)
                }
            ),
            rightItem: AnyView(
                Button(action: { withAnimation { isShelfMode.toggle() } }) {
                    Text(isShelfMode ? "⊞" : "≡")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 40, height: 40)
                }
            )
        )
    }

    private var contentView: some View {
        ZStack {
            if libraryService.isScanning {
                scanningView
            } else if libraryService.tracks.isEmpty {
                EmptyLibraryView {
                    libraryService.requestPermissionAndScan()
                }
            } else if isShelfMode {
                shelfScrollView
            } else {
                gridScrollView
            }
        }
    }

    private var scanningView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.2)
            Text("SCANNING...".localized)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
                .tracking(2)
        }
        .frame(maxHeight: .infinity)
    }

    private var shelfScrollView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(groupedAlbums, id: \.key) { group in
                    AlbumShelfRow(
                        albumName: group.key,
                        tracks: group.tracks,
                        isExpanded: expandedAlbum == group.key
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            expandedAlbum = (expandedAlbum == group.key) ? nil : group.key
                        }
                    } onTrackTap: { track in
                        player.play(track: track, in: group.tracks)
                        showPlayer = true
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private var gridScrollView: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(groupedAlbums, id: \.key) { group in
                    let firstTrack = group.tracks.first
                    let album = Album(
                        title: group.key,
                        artist: firstTrack?.artist ?? "Unknown",
                        coverImage: firstTrack?.artwork,
                        trackCount: group.tracks.count,
                        releaseYear: ""
                    )
                    
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        AlbumGridCard(
                            title: group.key,
                            artist: album.artist,
                            artwork: album.coverImage
                        )
                    }
                }
            }
            .padding(24)
        }
    }

    private var groupedAlbums: [AlbumGroup] {
        let dict = Dictionary(grouping: libraryService.tracks, by: { $0.album })
        let groups = dict.map { (key, value) -> AlbumGroup in
            let sortedTracks = value.sorted { $0.title < $1.title }
            return AlbumGroup(key: key, tracks: sortedTracks)
        }
        return groups.sorted { $0.key < $1.key }
    }
}

// MARK: - 辅助组件 (保持不变)

struct EmptyLibraryView: View {
    let onScan: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "music.note.list").font(.system(size: 64)).foregroundColor(AppColors.textSecondary.opacity(0.3))
            VStack(spacing: 8) {
                Text("YOUR LIBRARY IS EMPTY".localized).font(.system(size: 14, weight: .bold)).foregroundColor(AppColors.textPrimary)
                Text("Add music to your device or tap scan below".localized).font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary).multilineTextAlignment(.center)
            }.padding(.horizontal, 40)
            Button(action: onScan) {
                Text("SCAN LIBRARY".localized).font(.system(size: 14, weight: .bold)).foregroundColor(AppColors.textPrimary).frame(width: 200, height: 50).background(AppColors.background).skeuoRaised(cornerRadius: 25)
            }
        }.frame(maxHeight: .infinity)
    }
}

struct AlbumGroup {
    let key: String
    let tracks: [LocalTrack]
}

struct AlbumGridCard: View {
    let title: String; let artist: String; let artwork: UIImage?
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if let img = artwork { Image(uiImage: img).resizable().aspectRatio(contentMode: .fill) }
                else { Rectangle().fill(Color(hex: "#E0E0E0")); Image(systemName: "music.note").font(.system(size: 32)).foregroundColor(AppColors.textSecondary.opacity(0.4)) }
            }.frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fit).cornerRadius(4).clipped()
            Text(title).font(.system(size: 14, weight: .bold)).foregroundColor(AppColors.textPrimary).lineLimit(2).padding(.top, 10)
            Text(artist).font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary).lineLimit(1).padding(.top, 4)
        }.padding(0)
    }
}

struct AlbumShelfRow: View {
    let albumName: String; let tracks: [LocalTrack]; let isExpanded: Bool; let onTap: () -> Void; let onTrackTap: (LocalTrack) -> Void
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                ZStack(alignment: .leading) {
                    if let artwork = tracks.first?.artwork {
                        Image(uiImage: artwork).resizable().aspectRatio(contentMode: .fill).frame(height: 64).clipped().blur(radius: 8).overlay(Color.black.opacity(0.6))
                    } else { Color.black }
                    HStack {
                        Text("\(tracks.first?.artist ?? "Unknown") - \(albumName)").font(.system(size: 14, weight: .bold)).foregroundColor(.white).lineLimit(1)
                        Spacer(); Image(systemName: "chevron.right").font(.system(size: 12, weight: .bold)).foregroundColor(.white.opacity(0.7)).rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }.padding(.horizontal, 24)
                }.frame(maxWidth: .infinity).frame(height: 64)
            }.buttonStyle(PlainButtonStyle())
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(tracks.indices, id: \.self) { i in
                        Button(action: { onTrackTap(tracks[i]) }) {
                            HStack {
                                Text("\(i + 1).").font(.system(size: 14, weight: .regular)).foregroundColor(AppColors.textSecondary).frame(width: 28, alignment: .leading)
                                Text(tracks[i].title).font(.system(size: 14, weight: .medium)).foregroundColor(AppColors.textPrimary)
                                Spacer(); Text(formatDuration(tracks[i].duration)).font(.system(size: 12, weight: .regular)).foregroundColor(AppColors.textSecondary)
                            }.padding(.horizontal, 24).frame(height: 44).background(AppColors.background)
                        }.buttonStyle(PlainButtonStyle())
                        Divider().padding(.leading, 24)
                    }
                }.background(AppColors.background)
            }
        }
    }
}
