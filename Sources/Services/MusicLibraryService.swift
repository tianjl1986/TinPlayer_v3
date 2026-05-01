import Foundation
import MediaPlayer

// MARK: - 本地音乐库服务
class MusicLibraryService: ObservableObject {
    static let shared = MusicLibraryService()

    @Published var tracks: [LocalTrack] = []
    @Published var isScanning: Bool = false
    @Published var authorizationStatus: MPMediaLibraryAuthorizationStatus = .notDetermined

    private init() {
        authorizationStatus = MPMediaLibrary.authorizationStatus()
        if authorizationStatus == .authorized {
            scanLocalLibrary()
        }
    }

    // MARK: - 请求权限并扫描
    func requestPermissionAndScan() {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                if status == .authorized {
                    self?.scanLocalLibrary()
                }
            }
        }
    }

    // MARK: - 扫描本地库
    func scanLocalLibrary() {
        guard MPMediaLibrary.authorizationStatus() == .authorized else {
            requestPermissionAndScan()
            return
        }
        isScanning = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let query = MPMediaQuery.songs()
            query.groupingType = .title
            let items = query.items ?? []

            let localTracks: [LocalTrack] = items.compactMap { item in
                guard let title = item.title else { return nil }
                return LocalTrack(
                    persistentID: item.persistentID,
                    title: title,
                    artist: item.artist ?? "Unknown Artist",
                    album: item.albumTitle ?? "Unknown Album",
                    duration: item.playbackDuration,
                    artwork: item.artwork?.image(at: CGSize(width: 300, height: 300))
                )
            }

            DispatchQueue.main.async {
                self?.tracks = localTracks
                self?.isScanning = false
            }
        }
    }

    // MARK: - 清空库
    func clearLibrary() {
        tracks = []
    }
}

// MARK: - 曲目数据模型（加入persistentID）
struct LocalTrack: Identifiable {
    let id = UUID()
    let persistentID: MPMediaEntityPersistentID
    let title: String
    let artist: String
    let album: String
    let duration: TimeInterval
    let artwork: UIImage?
}
