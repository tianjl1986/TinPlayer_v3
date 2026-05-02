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
    
    var player: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentTrack: Track?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackMode: PlaybackMode = .list
    
    // 兼容旧代码的别名
    var playbackTime: TimeInterval { currentTime }
    
    private var timer: Timer?
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
    
    func playTrack(_ track: Track, in list: [Track] = []) {
        if !list.isEmpty { self.playlist = list }
        
        let url: URL
        if track.fileName.isEmpty {
            guard let bundleURL = Bundle.main.url(forResource: track.title, withExtension: "mp3") else { return }
            url = bundleURL
        } else {
            url = URL(fileURLWithPath: track.fileName)
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            self.currentTrack = track
            self.isPlaying = true
            self.duration = player?.duration ?? 0
            startTimer()
        } catch { print("Play error: \(error)") }
    }
    
    func togglePlayPause() {
        if isPlaying { pause() } else { resume() }
    }
    
    func pause() { player?.pause(); isPlaying = false; stopTimer() }
    func resume() { player?.play(); isPlaying = true; startTimer() }
    
    func skipNext() {
        guard !playlist.isEmpty, let current = currentTrack, let idx = playlist.firstIndex(where: { $0.id == current.id }) else { return }
        let nextIdx = (idx + 1) % playlist.count
        playTrack(playlist[nextIdx])
    }
    
    func skipPrevious() {
        guard !playlist.isEmpty, let current = currentTrack, let idx = playlist.firstIndex(where: { $0.id == current.id }) else { return }
        let prevIdx = (idx - 1 + playlist.count) % playlist.count
        playTrack(playlist[prevIdx])
    }
    
    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }
    
    func togglePlaybackMode() {
        switch playbackMode {
        case .list: playbackMode = .loop
        case .loop: playbackMode = .shuffle
        case .shuffle: playbackMode = .list
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentTime = self?.player?.currentTime ?? 0
        }
    }
    private func stopTimer() { timer?.invalidate() }
}
