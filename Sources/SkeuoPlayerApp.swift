import SwiftUI

@main
struct SkeuoPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            LibraryGridView()
                .preferredColorScheme(.light)
        }
    }
}
