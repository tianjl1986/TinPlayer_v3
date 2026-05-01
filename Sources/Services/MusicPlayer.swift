import Foundation
import MediaPlayer
import Combine

// MARK: - 音乐播放器（封装 MPMusicPlayerController）
class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()

    private let mpPlayer = MPMusicPlayerController.systemMusicPlayer

    @Published var currentTrack: LocalTrack?
    @Published var isPlaying: Bool = false
    @Published var playbackTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var timer: AnyCancellable?

    private init() {
        self.isPlaying = mpPlayer.playbackState == .playing
        setupNotifications()
        startTimer()
        // 读取当前正在播放的曲目
        if let item = mpPlayer.nowPlayingItem {
            updateFromMediaItem(item)
        }
    }

    // MARK: - 播放指定曲目
    func play(track: LocalTrack) {
        currentTrack = track
        duration = track.duration

        let query = MPMediaQuery.songs()
        let pred = MPMediaPropertyPredicate(
            value: track.persistentID,
            forProperty: MPMediaItemPropertyPersistentID
        )
        query.addFilterPredicate(pred)

        if let item = query.items?.first {
            mpPlayer.setQueue(with: MPMediaItemCollection(items: [item]))
            mpPlayer.play()
        }
    }

    // MARK: - 播放/暂停
    func togglePlayPause() {
        if mpPlayer.playbackState == .playing {
            mpPlayer.pause()
        } else {
            mpPlayer.play()
        }
    }

    // MARK: - 下一首
    func skipNext() {
        mpPlayer.skipToNextItem()
    }

    // MARK: - 上一首
    func skipPrevious() {
        if mpPlayer.currentPlaybackTime > 3 {
            mpPlayer.skipToBeginning()
        } else {
            mpPlayer.skipToPreviousItem()
        }
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
