import SwiftUI

struct HomeView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 1. Top Bar - 9904:14862
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SKEUOPLAYER")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(DesignTokens.textPrimary)
                            .padding(12)
                            .background(DesignTokens.surfaceMain)
                            .clipShape(Circle())
                            .skeuoRaised(cornerRadius: 20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 40) {
                        
                        // Section 0: CLASSIFICATION
                        VStack(alignment: .leading, spacing: 16) {
                            Text("CLASSIFICATION")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(DesignTokens.textSecondary)
                            
                            SkeuoSettingsGroup {
                                NavigationLink(destination: LibraryShelfView()) {
                                    SkeuoSettingsRow(title: "By Album", value: ">", isLink: true, showBackground: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider().padding(.horizontal, 20)
                                
                                NavigationLink(destination: ArtistListView()) {
                                    SkeuoSettingsRow(title: "By Artist", value: ">", isLink: true, showBackground: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Section 1: MEDIA LIBRARY (Quick Access)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("MEDIA LIBRARY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(DesignTokens.textSecondary)
                            
                            SkeuoSettingsGroup {
                                NavigationLink(destination: LibraryShelfView()) {
                                    SkeuoSettingsRow(title: "Browse All Music", value: ">", isLink: true, showBackground: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider().padding(.horizontal, 20)
                                
                                SkeuoSettingsRow(title: "Recently Added", value: "12 New", showBackground: false)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 32)
                }
                
                // Mini Player
                if player.currentTrack != nil {
                    NavigationLink(destination: NowPlayingView()) {
                        MiniPlayerView()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(DesignTokens.surfaceLight.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
