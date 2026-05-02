import Foundation
import AVFoundation
import MediaPlayer

enum PlaybackMode {
    case list, loopOne, shuffle
    var iconName: String {
        switch self {
        case .list: return "repeat"
        case .loopOne: return "repeat.1"
        case .shuffle: return "shuffle"
        }
    }
}

@MainActor
class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()
    
    var player: AVPlayer?
    private var playerObserver: Any?
    private var timeObserver: Any?
    
    @Published var isPlaying = false
    @Published var currentTrack: Track?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackMode: PlaybackMode = .list
    @Published var playlist: [Track] = []
    @Published var currentTrackLyrics: [LyricLine] = []
    @Published var currentLyricIndex: Int = 0
    @Published var isSearchingLyrics: Bool = false
    
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
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.resume() }
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }
    }
    
    func playTrack(_ track: Track, in list: [Track] = []) {
        if !list.isEmpty {
            self.playlist = list
        } else if self.playlist.isEmpty {
            self.playlist = [track]
        }
        
        self.currentTrack = track
        self.currentTrackLyrics = [] // 重置歌词
        
        // 🚀 触发在线歌词搜索
        Task {
            isSearchingLyrics = true
            let lyrics = await LyricsService.shared.searchLyrics(for: track.title, artist: track.artist)
            await MainActor.run {
                self.currentTrackLyrics = lyrics
                self.isSearchingLyrics = false
            }
        }
        
        let url: URL?
        // ... (保持原有的 URL 解析逻辑)
        if track.fileName.hasPrefix("ipod-library://") {
            url = URL(string: track.fileName)
        } else if track.fileName.isEmpty {
            url = Bundle.main.url(forResource: track.title, withExtension: "mp3")
        } else {
            url = URL(fileURLWithPath: track.fileName)
        }
        
        guard let validURL = url else {
            print("❌ Invalid URL for track: \(track.title)")
            return
        }
        
        // 清理旧的通知和观察者
        stopObserver()
        if let observer = playerObserver {
            NotificationCenter.default.removeObserver(observer)
            playerObserver = nil
        }
        
        let playerItem = AVPlayerItem(url: validURL)
        let newPlayer = AVPlayer(playerItem: playerItem)
        self.player = newPlayer
        
        Task {
            do {
                let duration = try await playerItem.asset.load(.duration)
                await MainActor.run {
                    self.duration = duration.seconds
                }
            } catch {
                print("❌ Failed to load duration: \(error)")
            }
        }
        
        newPlayer.play()
        self.isPlaying = true
        startObserver()
        
        // 监听播放结束，严格遵守播放模式
        playerObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                switch self.playbackMode {
                case .loopOne:
                    self.seek(to: 0)
                    self.resume()
                case .list:
                    // 如果是最后首则停止，否则下一首
                    if let current = self.currentTrack,
                       let idx = self.playlist.firstIndex(where: { $0.id == current.id }),
                       idx < self.playlist.count - 1 {
                        self.skipNext()
                    } else {
                        self.pause()
                        self.seek(to: 0)
                    }
                case .shuffle:
                    self.skipNext()
                }
            }
        }
    }
    
    func togglePlayPause() {
        if isPlaying { pause() } else { resume() }
    }
    
    func manualSearchLyrics() async {
        guard let track = currentTrack else { return }
        await MainActor.run { isSearchingLyrics = true }
        let lyrics = await LyricsService.shared.searchLyrics(for: track.title, artist: track.artist)
        await MainActor.run {
            self.currentTrackLyrics = lyrics
            self.isSearchingLyrics = false
        }
    }
    
    func pause() { player?.pause(); isPlaying = false }
    func resume() { player?.play(); isPlaying = true }
    
    func skipNext() {
        guard !playlist.isEmpty, let current = currentTrack, 
              let idx = playlist.firstIndex(where: { $0.id == current.id }) else { return }
        
        let nextIdx: Int
        if playbackMode == .shuffle {
            nextIdx = Int.random(in: 0..<playlist.count)
        } else {
            nextIdx = (idx + 1) % playlist.count
        }
        playTrack(playlist[nextIdx])
    }
    
    func skipPrevious() {
        guard !playlist.isEmpty, let current = currentTrack, 
              let idx = playlist.firstIndex(where: { $0.id == current.id }) else { return }
        
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
        case .list: playbackMode = .loopOne
        case .loopOne: playbackMode = .shuffle
        case .shuffle: playbackMode = .list
        }
    }
    
    private func stopObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    private func startObserver() {
        stopObserver()
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                guard let self = self else { return }
                self.currentTime = time.seconds
                
                // 🚀 同步歌词索引
                if let index = self.currentTrackLyrics.lastIndex(where: { $0.startTime <= time.seconds }) {
                    self.currentLyricIndex = index
                }
            }
        }
    }
}
