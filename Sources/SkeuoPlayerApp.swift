import SwiftUI

@main
struct SkeuoPlayerApp: App {
    @StateObject private var musicPlayer = MusicPlayer()
    @StateObject private var libraryService = MusicLibraryService()
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            LibraryGridView() // 🚀 直接进入书架
                .environmentObject(musicPlayer)
                .environmentObject(libraryService)
                .environmentObject(localizationManager)
                .preferredColorScheme(.dark) // 🚀 修复状态栏颜色
        }
    }
}
