import SwiftUI

@main
struct SkeuoPlayerApp: App {
    @StateObject private var musicPlayer = MusicPlayer()
    @StateObject private var libraryService = MusicLibraryService()
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            LibraryGridView()
                .environmentObject(musicPlayer)
                .environmentObject(libraryService)
                .environmentObject(localizationManager)
                .preferredColorScheme(.dark) // 🚀 确保系统状态栏变白
        }
    }
}
