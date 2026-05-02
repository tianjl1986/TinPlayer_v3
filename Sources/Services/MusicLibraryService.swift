import Foundation
import AVFoundation
import UIKit
import SwiftUI
import MediaPlayer

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
        
        // 🚀 核心修改：无论 autoScan 状态，启动即尝试获取权限并扫描
        // 这样可以确保系统弹出权限申请框
        scanLibrary()
    }
    
    func clearLibrary() {
        DispatchQueue.main.async {
            self.albums = []
        }
    }
    
    func scanLibrary() {
        self.isScanning = true
        clearLibrary()
        
        Task {
            // 🚀 核心优化：并行执行本地和系统库扫描，互不阻塞
            async let localScan: Void = scanLocalFolders()
            async let systemScan: Void = scanSystemLibrary()
            _ = await [localScan, systemScan]
            
            await MainActor.run {
                self.isScanning = false
            }
        }
    }
    
    private func scanSystemLibrary() async {
        let status = await withCheckedContinuation { continuation in
            MPMediaLibrary.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        if status == .authorized {
            let query = MPMediaQuery.albums()
            guard let collections = query.collections else { return }
            
            var tempSystemAlbums: [Album] = []
            for collection in collections {
                guard let representativeItem = collection.representativeItem else { continue }
                
                let albumTitle = representativeItem.albumTitle ?? "Unknown Album"
                let artist = representativeItem.artist ?? "Unknown Artist"
                let artwork = representativeItem.artwork?.image(at: CGSize(width: 300, height: 300))
                
                var tracks: [Track] = []
                for item in collection.items {
                    let track = Track(
                        title: item.title ?? "Unknown Track",
                        artist: item.artist ?? artist,
                        fileName: item.assetURL?.absoluteString ?? "",
                        duration: formatDuration(item.playbackDuration)
                    )
                    tracks.append(track)
                }
                
                let newAlbum = Album(
                    title: albumTitle,
                    artist: artist,
                    coverImage: artwork,
                    trackCount: collection.count,
                    releaseYear: "System Library",
                    tracks: tracks
                )
                tempSystemAlbums.append(newAlbum)
            }
            
            let finalSystemAlbums = tempSystemAlbums
            await MainActor.run {
                self.albums.append(contentsOf: finalSystemAlbums)
            }
        }
    }
    
    private func scanLocalFolders() async {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fm = FileManager.default
        
        // 🚀 核心修复：使用 while 循环替代 for-in 以兼容异步上下文
        guard let enumerator = fm.enumerator(at: docs, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles]) else { return }
        
        var tempAlbums: [Album] = []
        
        while let url = enumerator.nextObject() as? URL {
            let ext = url.pathExtension.lowercased()
            if ["mp3", "m4a", "flac"].contains(ext) {
                await parseMetadata(for: url, into: &tempAlbums)
            }
        }
        
        
        let finalAlbums = tempAlbums
        await MainActor.run {
            self.albums.append(contentsOf: finalAlbums)
        }
    }
    
    private func parseMetadata(for url: URL, into albumsList: inout [Album]) async {
        let asset = AVAsset(url: url)
        let titleVal = url.deletingPathExtension().lastPathComponent
        var title = titleVal
        var artist = "Unknown Artist"
        var albumName = "Local Music"
        var artwork: UIImage? = nil
        
        if let metadata = try? await asset.load(.metadata) {
            for item in metadata {
                guard let key = item.commonKey?.rawValue else { continue }
                let value = try? await item.load(.value)
                if key == "title", let s = value as? String { title = s }
                else if key == "artist", let s = value as? String { artist = s }
                else if key == "albumName", let s = value as? String { albumName = s }
                else if key == "artwork", let data = value as? Data { artwork = UIImage(data: data) }
            }
        }
        
        let durationValue = (try? await asset.load(.duration))?.seconds ?? 0
        let track = Track(title: title, artist: artist, fileName: url.path, duration: formatDuration(durationValue))
        
        if let idx = albumsList.firstIndex(where: { $0.title == albumName }) {
            albumsList[idx].tracks.append(track)
            // 🚀 现在可以修改 coverImage 了
            if albumsList[idx].coverImage == nil { albumsList[idx].coverImage = artwork }
        } else {
            albumsList.append(Album(title: albumName, artist: artist, coverImage: artwork, trackCount: 1, releaseYear: "2024", tracks: [track]))
        }
    }
}
