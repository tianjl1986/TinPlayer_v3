import Foundation
import MediaPlayer

class MusicPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var currentProgress: Double = 0
    @Published var currentSongTitle = "Random Access Memories"
    @Published var currentArtist = "Daft Punk"
    
    func togglePlayback() {
        isPlaying.toggle()
    }
    
    func skipForward() { }
    func skipBackward() { }
}

class LyricsService: ObservableObject {
    @Published var lyrics: [String] = ["Doin' it right", "Everybody will be dancing", "And we'll be feelin' it right"]
}
