import Foundation
import AVFoundation
import MediaPlayer

enum PlaybackMode {
    case list, loop, shuffle
    var iconName: String {
        switch self {
        case .list: return "repeat"
        case .loop: return "repeat.1"
        case .shuffle: return "shuffle"
        }
    }
}

class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()
    
    var player: AVPlayer?
    private var playerItemContext = 0
    
    @Published var isPlaying = false
    @Published var currentTrack: Track?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackMode: PlaybackMode = .list
    
    // 兼容旧代码的别名
    var playbackTime: TimeInterval { currentTime }
    
    private var timeObserver: Any?
    private var playlist: [Track] = []
    
    init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        try? session.setActive(true)
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] _ in self.resume(); return .success }
        commandCenter.pauseCommand.addTarget { [unowned self] _ in self.pause(); return .success }
    }
    
    private var playerObserver: Any?
    
    func playTrack(_ track: Track, in list: [Track] = []) {
        if !list.isEmpty { self.playlist = list }
        self.currentTrack = track
        
        let url: URL?
        if track.fileName.hasPrefix("ipod-library://") {
            url = URL(string: track.fileName)
        } else if track.fileName.isEmpty {
            url = Bundle.main.url(forResource: track.title, withExtension: "mp3")
        } else {
            url = URL(fileURLWithPath: track.fileName)
        }
        
        guard let validURL = url else { return }
        
        // 清理旧的通知监听
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        let playerItem = AVPlayerItem(url: validURL)
        player = AVPlayer(playerItem: playerItem)
        
        Task {
            if let duration = try? await playerItem.asset.load(.duration) {
                await MainActor.run {
                    self.duration = duration.seconds
                }
            }
        }
        
        player?.play()
        self.isPlaying = true
        startObserver()
        
        // 监听播放结束，严格遵守播放模式
        playerObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            if self.playbackMode == .loop {
                self.seek(to: 0)
                self.resume()
            } else {
                self.skipNext()
            }
        }
    }
    
    func togglePlayPause() {
        if isPlaying { pause() } else { resume() }
    }
    
    func pause() { player?.pause(); isPlaying = false }
    func resume() { player?.play(); isPlaying = true }
    
    func skipNext() {
        guard !playlist.isEmpty, let current = currentTrack, let idx = playlist.firstIndex(where: { $0.id == current.id }) else { return }
        
        let nextIdx: Int
        if playbackMode == .shuffle {
            nextIdx = Int.random(in: 0..<playlist.count)
        } else {
            nextIdx = (idx + 1) % playlist.count
        }
        playTrack(playlist[nextIdx])
    }
    
    func skipPrevious() {
        guard !playlist.isEmpty, let current = currentTrack, let idx = playlist.firstIndex(where: { $0.id == current.id }) else { return }
        
        let prevIdx: Int
        if playbackMode == .shuffle {
            prevIdx = Int.random(in: 0..<playlist.count)
        } else {
            prevIdx = (idx - 1 + playlist.count) % playlist.count
        }
        playTrack(playlist[prevIdx])
    }
    
    func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
    }
    
    func togglePlaybackMode() {
        switch playbackMode {
        case .list: playbackMode = .loop
        case .loop: playbackMode = .shuffle
        case .shuffle: playbackMode = .list
        }
    }
    
    private func startObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
}
