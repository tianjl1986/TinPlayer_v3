import SwiftUI

struct HomeView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @ObservedObject private var loc = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Standardized Header for consistency with other views
                AppHeader(
                    title: "SKEUOPLAYER",
                    rightItem: AnyView(
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(DesignTokens.textPrimary)
                        }
                    )
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 40) {
                        
                        // Section: CLASSIFICATION
                        VStack(alignment: .leading, spacing: 16) {
                            Text(loc.t("CLASSIFICATION"))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(DesignTokens.textSecondary)
                            
                            SkeuoSettingsGroup {
                                NavigationLink(destination: LibraryShelfView()) {
                                    SkeuoSettingsRow(title: loc.t("By Album"), value: ">", isLink: true, showBackground: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider().padding(.horizontal, 20)
                                
                                NavigationLink(destination: ArtistListView()) {
                                    SkeuoSettingsRow(title: loc.t("By Artist"), value: ">", isLink: true, showBackground: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Section: MEDIA LIBRARY (Quick Access)
                        VStack(alignment: .leading, spacing: 16) {
                            Text(loc.t("MEDIA LIBRARY"))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(DesignTokens.textSecondary)
                            
                            SkeuoSettingsGroup {
                                NavigationLink(destination: LibraryShelfView()) {
                                    SkeuoSettingsRow(title: loc.language == "en" ? "Browse All Music" : "浏览所有音乐", value: ">", isLink: true, showBackground: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider().padding(.horizontal, 20)
                                
                                SkeuoSettingsRow(title: loc.language == "en" ? "Recently Added" : "最近添加", value: "12 New", showBackground: false)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 24)
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

