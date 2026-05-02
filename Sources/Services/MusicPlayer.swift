import Foundation
import MediaPlayer
import Combine

// MARK: - 播放模式
enum PlaybackMode: Int, CaseIterable {
    case sequence = 0 // 列表循环
    case repeatOne = 1 // 单曲循环
    case shuffle   = 2 // 随机播放

    var iconName: String {
        switch self {
        case .sequence: return "repeat"
        case .repeatOne: return "repeat.1"
        case .shuffle: return "shuffle"
        }
    }
    
    var localizedName: String {
        switch self {
        case .sequence: return "列表循环"
        case .repeatOne: return "单曲循环"
        case .shuffle: return "随机播放"
        }
    }
}

// MARK: - 音乐播放器（封装 MPMusicPlayerController）
class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()

    private let mpPlayer = MPMusicPlayerController.systemMusicPlayer

    @Published var currentTrack: LocalTrack? {
        didSet {
            if let track = currentTrack {
                LyricsService.shared.fetchLyrics(for: track.title, artist: track.artist)
            }
        }
    }
    @Published var isPlaying: Bool = false
    @Published var playbackTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackMode: PlaybackMode = .sequence {
        didSet { applyPlaybackMode() }
    }

    private var playlist: [LocalTrack] = []
    private var timer: AnyCancellable?

    private init() {
        self.isPlaying = mpPlayer.playbackState == .playing
        // 恢复播放模式状态
        if mpPlayer.shuffleMode != .off {
            playbackMode = .shuffle
        } else if mpPlayer.repeatMode == .one {
            playbackMode = .repeatOne
        } else {
            playbackMode = .sequence
        }
        
        setupNotifications()
        startTimer()
        // 读取当前正在播放的曲目
        if let item = mpPlayer.nowPlayingItem {
            updateFromMediaItem(item)
        }
    }

    // MARK: - 播放指定曲目并设置列表
    func play(track: LocalTrack, in list: [LocalTrack]? = nil) {
        currentTrack = track
        duration = track.duration
        
        if let list = list {
            self.playlist = list
            let items = fetchMediaItems(for: list)
            if !items.isEmpty {
                let collection = MPMediaItemCollection(items: items)
                mpPlayer.setQueue(with: collection)
                // 查找目标曲目在集合中的位置
                if let targetItem = items.first(where: { $0.persistentID == track.persistentID }) {
                    mpPlayer.nowPlayingItem = targetItem
                }
            }
        } else {
            // 单曲播放
            let items = fetchMediaItems(for: [track])
            if let item = items.first {
                mpPlayer.setQueue(with: MPMediaItemCollection(items: [item]))
            }
        }
        
        applyPlaybackMode()
        mpPlayer.play()
    }

    private func fetchMediaItems(for tracks: [LocalTrack]) -> [MPMediaItem] {
        let ids = tracks.map { $0.persistentID }
        let query = MPMediaQuery.songs()
        let pred = MPMediaPropertyPredicate(value: ids, forProperty: MPMediaItemPropertyPersistentID, comparisonType: .equalTo)
        query.addFilterPredicate(pred)
        return query.items ?? []
    }

    // MARK: - 播放/暂停
    func togglePlayPause() {
        if mpPlayer.playbackState == .playing {
            mpPlayer.pause()
        } else {
            mpPlayer.play()
        }
    }

    // MARK: - 切换播放模式
    func togglePlaybackMode() {
        let allCases = PlaybackMode.allCases
        let nextIndex = (playbackMode.rawValue + 1) % allCases.count
        playbackMode = allCases[nextIndex]
    }

    private func applyPlaybackMode() {
        switch playbackMode {
        case .sequence:
            mpPlayer.shuffleMode = .off
            mpPlayer.repeatMode = .all
        case .repeatOne:
            mpPlayer.shuffleMode = .off
            mpPlayer.repeatMode = .one
        case .shuffle:
            mpPlayer.shuffleMode = .songs
            mpPlayer.repeatMode = .all
        }
    }

    // MARK: - 下一首
    func skipNext() {
        mpPlayer.skipToNextItem()
        // 如果是暂停状态，切换后自动播放
        if !isPlaying { mpPlayer.play() }
    }

    // MARK: - 上一首
    func skipPrevious() {
        if mpPlayer.currentPlaybackTime > 3 {
            mpPlayer.skipToBeginning()
        } else {
            mpPlayer.skipToPreviousItem()
        }
        if !isPlaying { mpPlayer.play() }
    }

    // MARK: - 跳转进度
    func seek(to time: TimeInterval) {
        mpPlayer.currentPlaybackTime = time
        playbackTime = time
    }

    // MARK: - 通知监听
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: nil, queue: .main
        ) { [weak self] _ in
            self?.isPlaying = self?.mpPlayer.playbackState == .playing
        }

        NotificationCenter.default.addObserver(
            forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: nil, queue: .main
        ) { [weak self] _ in
            if let item = self?.mpPlayer.nowPlayingItem {
                self?.updateFromMediaItem(item)
            }
        }

        mpPlayer.beginGeneratingPlaybackNotifications()
    }

    private func updateFromMediaItem(_ item: MPMediaItem) {
        let artworkImage = item.artwork?.image(at: CGSize(width: 300, height: 300))
        currentTrack = LocalTrack(
            persistentID: item.persistentID,
            title: item.title ?? "Unknown",
            artist: item.artist ?? "Unknown Artist",
            album: item.albumTitle ?? "Unknown Album",
            duration: item.playbackDuration,
            artwork: artworkImage
        )
        duration = item.playbackDuration
    }

    // MARK: - 定时器（每0.5s更新进度）
    private func startTimer() {
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let t = self.mpPlayer.currentPlaybackTime
                if t.isFinite && !t.isNaN { self.playbackTime = t }
            }
    }
}
