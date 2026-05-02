import Foundation
import AVFoundation
import UIKit

class MusicLibraryService: ObservableObject {
    @Published var albums: [Album] = Album.sampleData
    @Published var isScanning = false
    @Published var mediaFolders: [String] = []
    
    init() {
        loadSettings()
        // 如果没有设置过路径，给一个默认的 iOS 文档路径
        if mediaFolders.isEmpty {
            let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""
            mediaFolders = [docPath]
        }
    }
    
    private func loadSettings() {
        self.mediaFolders = UserDefaults.standard.stringArray(forKey: "media_folders") ?? []
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(mediaFolders, forKey: "media_folders")
    }
    
    func addFolder(_ path: String) {
        if !mediaFolders.contains(path) {
            mediaFolders.append(path)
            saveSettings()
        }
    }
    
    // 🚀 核心：真正的深度递归扫描
    func scanLibrary() {
        guard !isScanning else { return }
        isScanning = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            var newAlbums: [Album] = Album.sampleData // 保留内置专辑
            let fm = FileManager.default
            
            for folder in self.mediaFolders {
                let url = URL(fileURLWithPath: folder)
                guard let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) else { continue }
                
                for case let fileURL as URL in enumerator {
                    let ext = fileURL.pathExtension.lowercased()
                    if ["mp3", "m4a", "flac", "wav"].contains(ext) {
                        self.parseMetadata(for: fileURL, into: &newAlbums)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.albums = newAlbums
                self.isScanning = false
            }
        }
    }
    
    // 🚀 核心：解析 ID3 / MP4 标签
    private func parseMetadata(for url: URL, into albumsList: inout [Album]) {
        let asset = AVAsset(url: url)
        let metadata = asset.metadata
        
        var title = url.deletingPathExtension().lastPathComponent
        var artist = "Unknown Artist"
        var albumName = "Unknown Album"
        
        // 尝试从元数据中提取信息
        for item in metadata {
            guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
            switch key {
            case "title": title = value as? String ?? title
            case "artist": artist = value as? String ?? artist
            case "albumName": albumName = value as? String ?? albumName
            default: break
            }
        }
        
        let track = Track(title: title, duration: "--:--", fileName: url.path)
        
        // 分组逻辑
        if let idx = albumsList.firstIndex(where: { $0.title == albumName }) {
            if !albumsList[idx].tracks.contains(where: { $0.title == track.title }) {
                albumsList[idx].tracks.append(track)
            }
        } else {
            let newAlbum = Album(
                title: albumName,
                artist: artist,
                coverImageName: "default_cover",
                trackCount: 1,
                releaseYear: "--",
                tracks: [track]
            )
            albumsList.append(newAlbum)
        }
    }
}
