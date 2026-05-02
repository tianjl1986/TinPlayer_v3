import Foundation
import AVFoundation
import UIKit

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
        
        Task {
            var newAlbums = Album.sampleData
            let fm = FileManager.default
            
            for folder in self.mediaFolders {
                let url = URL(fileURLWithPath: folder)
                if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey]) {
                    for case let fileURL as URL in enumerator {
                        if ["mp3", "m4a", "flac"].contains(fileURL.pathExtension.lowercased()) {
                            await self.parseMetadata(for: fileURL, into: &newAlbums)
                        }
                    }
                }
            }
            
            await MainActor.run {
                self.albums = newAlbums
                self.isScanning = false
            }
        }
    }
    
    private func parseMetadata(for url: URL, into albumsList: inout [Album]) async {
        let asset = AVAsset(url: url)
        var title = url.deletingPathExtension().lastPathComponent
        var artist = "Unknown Artist"
        var albumName = "Local Music"
        
        // 🚀 使用 iOS 16+ 推荐的异步加载方式
        if let metadata = try? await asset.load(.metadata) {
            for item in metadata {
                guard let key = item.commonKey?.rawValue else { continue }
                let value = try? await item.load(.value)
                
                if let stringValue = value as? String {
                    if key == "title" { title = stringValue }
                    else if key == "artist" { artist = stringValue }
                    else if key == "albumName" { albumName = stringValue }
                }
            }
        }
        
        let track = Track(title: title, artist: artist, fileName: url.path, duration: "--:--")
        
        if let idx = albumsList.firstIndex(where: { $0.title == albumName }) {
            if !albumsList[idx].tracks.contains(where: { $0.title == track.title }) {
                albumsList[idx].tracks.append(track)
            }
        } else {
            albumsList.append(Album(
                title: albumName,
                artist: artist,
                coverImage: nil, // 🚀 修复属性名不匹配问题
                trackCount: 1,
                releaseYear: "2024",
                tracks: [track]
            ))
        }
    }
}
