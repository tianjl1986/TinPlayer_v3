import Foundation
import AVFoundation
import UIKit
import SwiftUI

class MusicLibraryService: ObservableObject {
    static let shared = MusicLibraryService()
    
    @Published var albums: [Album] = []
    @Published var isScanning = false
    @Published var mediaFolders: [String] = []
    
    @AppStorage("parse_cue") var parseCue = true
    @AppStorage("search_lrc") var searchLrc = true
    @AppStorage("auto_scan") var autoScan = false
    
    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "media_folders") ?? []
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""
        self.mediaFolders = saved.isEmpty ? [docs] : saved
        
        // 如果为空且有默认文件夹，且开启了自动扫描，则扫描
        if self.albums.isEmpty {
            self.albums = Album.sampleData // 默认保留样例数据，直到扫描到新东西
        }
        
        if autoScan {
            scanLibrary()
        }
    }
    
    func clearLibrary() {
        self.albums = []
    }
    
    func scanLibrary() {
        guard !isScanning else { return }
        isScanning = true
        
        Task {
            var newAlbums: [Album] = []
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
        var artwork: UIImage? = nil
        
        if let metadata = try? await asset.load(.metadata) {
            for item in metadata {
                guard let key = item.commonKey?.rawValue else { continue }
                let value = try? await item.load(.value)
                
                if key == "title", let stringValue = value as? String { title = stringValue }
                else if key == "artist", let stringValue = value as? String { artist = stringValue }
                else if key == "albumName", let stringValue = value as? String { albumName = stringValue }
                else if key == "artwork", let data = value as? Data { artwork = UIImage(data: data) }
            }
        }
        
        // 🚀 获取时长
        let durationValue = (try? await asset.load(.duration))?.seconds ?? 0
        let durationStr = formatDuration(durationValue)
        
        let track = Track(title: title, artist: artist, fileName: url.path, duration: durationStr)
        
        if let idx = albumsList.firstIndex(where: { $0.title == albumName }) {
            if !albumsList[idx].tracks.contains(where: { $0.title == track.title }) {
                albumsList[idx].tracks.append(track)
                // 如果专辑还没有封面，用这个曲目的
                if albumsList[idx].coverImage == nil {
                    albumsList[idx].coverImage = artwork
                }
            }
        } else {
            albumsList.append(Album(
                title: albumName,
                artist: artist,
                coverImage: artwork,
                trackCount: 1,
                releaseYear: "2024",
                tracks: [track]
            ))
        }
    }
}
