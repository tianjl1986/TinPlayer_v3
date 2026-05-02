import SwiftUI

@main
struct SkeuoPlayerApp: App {
    // 🚀 使用 @StateObject 维持单例生命周期
    @StateObject private var musicPlayer = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            LibraryGridView()
                .environmentObject(musicPlayer)
                .environmentObject(libraryService)
                .environmentObject(localizationManager)
                .preferredColorScheme(.dark) // 🚀 修复：强制深色模式，使状态栏图标变白
        }
    }
}
