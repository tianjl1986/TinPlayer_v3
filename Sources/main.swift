import SwiftUI

struct SkeuoPlayerApp: App {
    @StateObject private var musicPlayer = MusicPlayer.shared
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(musicPlayer)
                .environmentObject(libraryService)
                .environmentObject(localizationManager)
                .preferredColorScheme(.light)
        }
    }
}

SkeuoPlayerApp.main()
