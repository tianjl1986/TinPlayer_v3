import SwiftUI

struct HomeView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @State private var isScanning = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        // 1. App Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SKEUOPLAYER")
                                    .font(.system(size: 24, weight: .black))
                                    .tracking(2)
                                    .foregroundColor(DesignTokens.textPrimary)
                                
                                if isScanning {
                                    Text("SCANNING LIBRARY...")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(DesignTokens.textActive)
                                }
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(DesignTokens.textSecondary)
                                    .frame(width: 44, height: 44)
                                    .skeuoRaised(cornerRadius: 12)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // 2. Main Navigation Grid (Foobar2000 Style)
                        VStack(spacing: 24) {
                            HStack(spacing: 24) {
                                NavigationLink(destination: LibraryGridView()) {
                                    HomeNavCard(title: "ALBUMS", icon: "square.stack.fill", count: libraryService.albums.count)
                                }
                                
                                NavigationLink(destination: LibraryGridView()) {
                                    HomeNavCard(title: "ARTISTS", icon: "person.2.fill", count: Set(libraryService.albums.map { $0.artist }).count)
                                }
                            }
                            
                            HStack(spacing: 24) {
                                NavigationLink(destination: LibraryGridView()) {
                                    HomeNavCard(title: "FOLDERS", icon: "folder.fill", count: libraryService.mediaFolders.count)
                                }
                                
                                NavigationLink(destination: LibraryGridView()) {
                                    HomeNavCard(title: "PLAYLISTS", icon: "music.note.list", count: 0)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // 3. Recently Played
                        VStack(alignment: .leading, spacing: 20) {
                            Text("RECENTLY PLAYED")
                                .font(.system(size: 12, weight: .black))
                                .tracking(1)
                                .foregroundColor(DesignTokens.textSecondary)
                                .padding(.horizontal, 24)
                            
                            if libraryService.playlist.isEmpty {
                                // Empty State
                                Button(action: { performInitialScan() }) {
                                    VStack(spacing: 16) {
                                        Image(systemName: "music.note.list")
                                            .font(.system(size: 40))
                                        Text("TAP TO SCAN MEDIA")
                                            .font(.system(size: 14, weight: .black))
                                    }
                                    .foregroundColor(DesignTokens.textSecondary.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 180)
                                    .skeuoSunken(cornerRadius: 24)
                                    .padding(.horizontal, 24)
                                }
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(libraryService.playlist.prefix(5)) { track in
                                            Button(action: { player.playTrack(track) }) {
                                                VStack(alignment: .leading, spacing: 12) {
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .fill(DesignTokens.surfaceMain)
                                                        .frame(width: 140, height: 140)
                                                        .skeuoRaised(cornerRadius: 16)
                                                        .overlay(
                                                            Image(systemName: "music.note")
                                                                .font(.system(size: 40))
                                                                .foregroundColor(DesignTokens.textSecondary.opacity(0.3))
                                                        )
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(track.title.uppercased())
                                                            .font(.system(size: 12, weight: .black))
                                                            .foregroundColor(DesignTokens.textPrimary)
                                                            .lineLimit(1)
                                                        Text(track.artist.uppercased())
                                                            .font(.system(size: 10, weight: .bold))
                                                            .foregroundColor(DesignTokens.textSecondary)
                                                            .lineLimit(1)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                        
                        Spacer(minLength: 120)
                    }
                }
                
                // Mini Player
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
            await libraryService.scanLibrary()
            await MainActor.run {
                isScanning = false
            }
        }
    }
}

struct HomeNavCard: View {
    let title: String
    let icon: String
    let count: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(DesignTokens.textPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                Text("\(count) ITEMS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DesignTokens.surfaceMain)
                .skeuoRaised(cornerRadius: 20)
        )
    }
}
