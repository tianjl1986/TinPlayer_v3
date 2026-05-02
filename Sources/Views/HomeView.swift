import SwiftUI

struct HomeView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Top Bar
                        TopBarView()
                        
                        // Categories / Quick Navigation
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                NavigationLink(destination: LibraryGridView()) {
                                    HomeCategoryCard(title: "Library", icon: "music.note.list", color: .blue)
                                }
                                
                                NavigationLink(destination: SettingsView()) {
                                    HomeCategoryCard(title: "Settings", icon: "gearshape.fill", color: .gray)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Recent / Recommendation Section
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text("Recently Played")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                NavigationLink(destination: LibraryGridView()) {
                                    Text("See All")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppColors.textActive)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(libraryService.playlist.prefix(5)) { track in
                                        Button(action: { player.playTrack(track) }) {
                                            VStack(alignment: .leading, spacing: 12) {
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.gray.opacity(0.1))
                                                    .frame(width: 160, height: 160)
                                                    .skeuoRaised(cornerRadius: 16)
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(track.title)
                                                        .font(.system(size: 15, weight: .bold))
                                                        .foregroundColor(AppColors.textPrimary)
                                                        .lineLimit(1)
                                                    Text(track.artist)
                                                        .font(.system(size: 13, weight: .medium))
                                                        .foregroundColor(AppColors.textSecondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.vertical, 20)
                }
                
                // Mini Player
                if player.currentTrack != nil {
                    MiniPlayerView()
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct HomeCategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppColors.textPrimary)
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(width: 100, height: 100)
        .skeuoRaised(cornerRadius: 20)
    }
}
