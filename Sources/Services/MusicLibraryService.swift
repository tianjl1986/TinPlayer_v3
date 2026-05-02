import Foundation
import AVFoundation

class MusicLibraryService: ObservableObject {
    static let shared = MusicLibraryService()
    
    @Published var albums: [Album] = Album.sampleData
    @Published var isScanning = false
    @Published var mediaFolders: [String] = []
    
    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "media_folders") ?? []
        self.mediaFolders = saved.isEmpty ? [FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""] : saved
    }
    
    func scanLibrary() {
        guard !isScanning else { return }
        isScanning = true
        DispatchQueue.global(qos: .userInitiated).async {
            var newAlbums = Album.sampleData
            let fm = FileManager.default
            for folder in self.mediaFolders {
                let url = URL(fileURLWithPath: folder)
                if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey]) {
                    for case let fileURL as URL in enumerator {
                        if ["mp3", "m4a", "flac"].contains(fileURL.pathExtension.lowercased()) {
                            self.parseMetadata(for: fileURL, into: &newAlbums)
                        }
                    }
                }
            }
            DispatchQueue.main.async { self.albums = newAlbums; self.isScanning = false }
        }
    }
    
    private func parseMetadata(for url: URL, into albumsList: inout [Album]) {
        let asset = AVAsset(url: url)
        var title = url.deletingPathExtension().lastPathComponent
        var artist = "Unknown Artist"
        var albumName = "Local Music"
        
        let metadata = asset.metadata
        for item in metadata {
            guard let key = item.commonKey?.rawValue, let value = item.value as? String else { continue }
            if key == "title" { title = value }
            if key == "artist" { artist = value }
            if key == "albumName" { albumName = value }
        }
        
        let track = Track(title: title, duration: "--:--", fileName: url.path)
        if let idx = albumsList.firstIndex(where: { $0.title == albumName }) {
            if !albumsList[idx].tracks.contains(where: { $0.title == track.title }) {
                albumsList[idx].tracks.append(track)
            }
        } else {
            albumsList.append(Album(title: albumName, artist: artist, coverImageName: "default_cover", trackCount: 1, releaseYear: "2024", tracks: [track]))
        }
    }
}
