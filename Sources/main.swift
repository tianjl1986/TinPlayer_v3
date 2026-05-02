import SwiftUI

struct SkeuoPlayerApp: App {
    // 🚀 使用 @StateObject 维持单例生命周期
    @StateObject private var musicPlayer = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            LibraryGridView()
                .environmentObject(musicPlayer)
                .environmentObject(libraryService)
                .environmentObject(localizationManager)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme == .light ? .light : .dark)
        }
    }
}

SkeuoPlayerApp.main()
