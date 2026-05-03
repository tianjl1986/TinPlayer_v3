import SwiftUI

struct HomeView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @State private var isScanning = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // 1. App Header (Matching Settings Style)
                        HStack {
                            Text("SKEUOPLAYER")
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(DesignTokens.textPrimary)
                            
                            Spacer()
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(DesignTokens.textSecondary)
                                    .frame(width: 48, height: 48)
                                    .skeuoRaised(cornerRadius: 14)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // 2. Navigation Grid (Image 1 Style)
                        VStack(spacing: 20) {
                            HStack(spacing: 20) {
                                NavigationLink(destination: LibraryShelfView()) {
                                    HomeNavCard(title: "ALBUMS", icon: "square.stack.fill", count: libraryService.albums.count)
                                }
                                
                                NavigationLink(destination: ArtistListView()) {
                                    HomeNavCard(title: "ARTISTS", icon: "person.2.fill", count: Set(libraryService.albums.map { $0.artist }).count)
                                }
                            }
                            
                            HStack(spacing: 20) {
                                NavigationLink(destination: LibraryGridView()) {
                                    HomeNavCard(title: "FOLDERS", icon: "folder.fill", count: libraryService.mediaFolders.count)
                                }
                                
                                NavigationLink(destination: LibraryGridView()) {
                                    HomeNavCard(title: "PLAYLISTS", icon: "music.note.list", count: 0)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // 3. Recently Played Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("RECENTLY PLAYED")
                                .font(.system(size: 13, weight: .black))
                                .tracking(1)
                                .foregroundColor(DesignTokens.textSecondary)
                                .padding(.horizontal, 24)
                            
                            if libraryService.playlist.isEmpty {
                                // Empty State Row
                                HStack {
                                    Image(systemName: "music.note")
                                        .foregroundColor(DesignTokens.textSecondary)
                                    Text("No music found. Scan to start.")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(DesignTokens.textSecondary)
                                }
                                .padding(24)
                                .frame(maxWidth: .infinity)
                                .skeuoSunken(cornerRadius: 16)
                                .padding(.horizontal, 24)
                                .onTapGesture { performInitialScan() }
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(libraryService.playlist.prefix(6)) { track in
                                            NavigationLink(destination: NowPlayingView().onAppear { player.playTrack(track) }) {
                                                RecentTrackCard(track: track)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                        
                        Spacer(minLength: 120)
                    }
                }
                
                // Mini Player Overlay
                if player.currentTrack != nil {
                    NavigationLink(destination: NowPlayingView()) {
                        MiniPlayerView()
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(DesignTokens.surfaceMain.ignoresSafeArea())
            .navigationBarHidden(true)
            .onAppear {
                if libraryService.albums.isEmpty {
                    performInitialScan()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func performInitialScan() {
        isScanning = true
        Task {
            libraryService.scanLibrary()
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run { isScanning = false }
        }
    }
}

struct HomeNavCard: View {
    let title: String
    let icon: String
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(DesignTokens.textPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                Text("\(count) ITEMS")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(DesignTokens.surfaceMain)
                .skeuoRaised(cornerRadius: 24)
        )
    }
}

struct RecentTrackCard: View {
    let track: Track
    @StateObject private var libraryService = MusicLibraryService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(DesignTokens.surfaceMain)
                    .frame(width: 150, height: 150)
                    .skeuoRaised(cornerRadius: 18)
                
                if let album = libraryService.albums.first(where: { $0.tracks.contains(track) }),
                   let cover = album.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 138, height: 138)
                        .cornerRadius(14)
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 40))
                        .foregroundColor(DesignTokens.textSecondary.opacity(0.2))
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title.uppercased())
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                    .lineLimit(1)
                Text(track.artist.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(width: 150)
    }
}
