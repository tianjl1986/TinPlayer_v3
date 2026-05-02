import SwiftUI

// MARK: - 音乐库页（1:1 还原 Figma 9897:14820 / 9897:14821）
// Grid视图：MY COLLECTION，两列专辑网格
// Bookshelf视图：MY COLLECTION，专辑+曲目列表
struct LibraryGridView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var player = MusicPlayer.shared
    @State private var showSettings = false
    @State private var showPlayer = false
    @State private var isShelfMode = false   // false=Grid，true=Bookshelf
    @State private var expandedAlbum: String? = nil

    // 两列网格
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── Top Bar（Figma: MY COLLECTION，左<，右=）──
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

                // ── 内容区 ──
                ZStack {
                    if libraryService.isScanning {
                        // 扫描中
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("SCANNING...".localized)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppColors.textSecondary)
                                .tracking(2)
                        }
                        .frame(maxHeight: .infinity)

                    } else if libraryService.tracks.isEmpty {
                        // 空库提示
                        EmptyLibraryView {
                            libraryService.requestPermissionAndScan()
                        }

                    } else if isShelfMode {
                        // ── Bookshelf 模式（按专辑分组）──
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
                    } else {
                        // ── Grid 模式（两列专辑封面）──
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(groupedAlbums, id: \.key) { group in
                                    NavigationLink(destination: AlbumDetailView(album: Album(title: group.key, artist: group.tracks.first?.artist ?? "Unknown"))) {
                                        AlbumGridCard(
                                            title: group.key,
                                            artist: group.tracks.first?.artist ?? "",
                                            artwork: group.tracks.first?.artwork
                                        )
                                    }
                                }
                            }
                            .padding(24)
                        }
                    }
                }
            }
            .background(AppColors.background)
            .ignoresSafeArea(edges: .bottom)
            .sheet(isPresented: $showSettings) { SettingsView() }
            .fullScreenCover(isPresented: $showPlayer) { NowPlayingView() }
            .onAppear {
                // 自动扫描（已授权时）
                if libraryService.tracks.isEmpty {
                    libraryService.requestPermissionAndScan()
                }
            }
        }
    }

    // 按专辑分组 (优化后的编译器友好版本)
    private var groupedAlbums: [AlbumGroup] {
        let dict = Dictionary(grouping: libraryService.tracks, by: { $0.album })
        let groups = dict.map { (key, value) -> AlbumGroup in
            let sortedTracks = value.sorted { $0.title < $1.title }
            return AlbumGroup(key: key, tracks: sortedTracks)
        }
        return groups.sorted { $0.key < $1.key }
    }
}

struct AlbumGroup {
    let key: String
    let tracks: [LocalTrack]
}

// MARK: - 网格专辑卡片
struct AlbumGridCard: View {
    let title: String
    let artist: String
    let artwork: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 封面图
            ZStack {
                if let img = artwork {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color(hex: "#E0E0E0"))
                    Image(systemName: "music.note")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.textSecondary.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(4)
            .clipped()

            // 标题
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 艺术家
            Text(artist)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
                .padding(.top, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(0)
    }
}

// MARK: - Bookshelf 专辑行
struct AlbumShelfRow: View {
    let albumName: String
    let tracks: [LocalTrack]
    let isExpanded: Bool
    let onTap: () -> Void
    let onTrackTap: (LocalTrack) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 专辑标题行
            Button(action: onTap) {
                ZStack(alignment: .leading) {
                    if let artwork = tracks.first?.artwork {
                        Image(uiImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 64)
                            .clipped()
                            .blur(radius: 8)
                            .overlay(Color.black.opacity(0.6))
                    } else {
                        Color.black
                    }

                    HStack {
                        Text("\(tracks.first?.artist ?? "Unknown") - \(albumName)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 64)
            }
            .buttonStyle(PlainButtonStyle())

            // 展开的曲目列表
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(tracks.indices, id: \.self) { i in
                        Button(action: { onTrackTap(tracks[i]) }) {
                            HStack {
                                Text("\(i + 1).")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppColors.textSecondary)
                                    .frame(width: 28, alignment: .leading)
                                
                                Text(tracks[i].title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Text(formatDuration(tracks[i].duration))
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 44)
                            .background(AppColors.background)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider().padding(.leading, 24)
                    }
                }
                .background(AppColors.background)
            }
        }
    }
}
