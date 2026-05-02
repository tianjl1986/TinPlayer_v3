import Foundation
import AVFoundation
import MediaPlayer

class MusicPlayer: ObservableObject {
    var player: AVAudioPlayer?
    @Published var isPlaying = false
    @Published var currentTrack: Track?
    @Published var currentTime: TimeInterval = 0
    
    private var timer: Timer?
    
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
    
    func playTrack(_ track: Track) {
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
            startTimer()
        } catch { print("Play error: \(error)") }
    }
    
    func pause() { player?.pause(); isPlaying = false; stopTimer() }
    func resume() { player?.play(); isPlaying = true; startTimer() }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.currentTime = self?.player?.currentTime ?? 0
        }
    }
    private func stopTimer() { timer?.invalidate() }
}
