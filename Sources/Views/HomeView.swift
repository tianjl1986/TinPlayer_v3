import SwiftUI

struct HomeView: View {
    @StateObject private var player = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    
    @AppStorage("app_language") private var appLanguage: String = "English"
    
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
                        
                        // Section 0: CLASSIFICATION
                        VStack(alignment: .leading, spacing: 16) {
                            Text(appLanguage == "English" ? "CLASSIFICATION" : "分类")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(DesignTokens.textSecondary)
                            
                            SkeuoSettingsGroup {
                                NavigationLink(destination: LibraryShelfView()) {
                                    SkeuoSettingsRow(title: appLanguage == "English" ? "By Album" : "按专辑", value: ">", isLink: true, showBackground: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider().padding(.horizontal, 20)
                                
                                NavigationLink(destination: ArtistListView()) {
                                    SkeuoSettingsRow(title: appLanguage == "English" ? "By Artist" : "按歌手", value: ">", isLink: true, showBackground: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Section 1: MEDIA LIBRARY (Quick Access)
                        VStack(alignment: .leading, spacing: 16) {
                            Text(appLanguage == "English" ? "MEDIA LIBRARY" : "媒体库")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(DesignTokens.textSecondary)
                            
                            SkeuoSettingsGroup {
                                NavigationLink(destination: LibraryShelfView()) {
                                    SkeuoSettingsRow(title: appLanguage == "English" ? "Browse All Music" : "浏览所有音乐", value: ">", isLink: true, showBackground: false)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Divider().padding(.horizontal, 20)
                                
                                SkeuoSettingsRow(title: appLanguage == "English" ? "Recently Added" : "最近添加", value: "12 New", showBackground: false)
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
            .transaction { transaction in
                transaction.animation = nil
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
