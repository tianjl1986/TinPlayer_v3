import Foundation
import AVFoundation
import MediaPlayer

class MusicPlayer: ObservableObject {
    var player: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentTrack: Track?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    private var timer: Timer?
    
    init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    // 🚀 保留：系统锁屏控制中心
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] _ in
            self.resume()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            self.pause()
            return .success
        }
    }
    
    func playTrack(_ track: Track) {
        // 如果文件路径为空，尝试寻找本地文件
        let url: URL
        if track.fileName.isEmpty {
            // 兼容模拟数据：尝试加载 Bundle 内的测试文件
            guard let bundleURL = Bundle.main.url(forResource: track.title, withExtension: "mp3") else {
                print("❌ 找不到文件: \(track.title)")
                return
            }
            url = bundleURL
        } else {
            url = URL(fileURLWithPath: track.fileName)
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
            
            self.currentTrack = track
            self.isPlaying = true
            self.duration = player?.duration ?? 0
            
            startTimer()
            updateNowPlayingInfo(track: track)
        } catch {
            print("❌ 播放失败: \(error)")
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func resume() {
        player?.play()
        isPlaying = true
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentTime = self?.player?.currentTime ?? 0
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    // 🚀 保留：更新锁屏信息
    private func updateNowPlayingInfo(track: Track) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.duration
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
