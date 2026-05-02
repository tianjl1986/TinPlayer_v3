import Foundation

class LyricsService {
    static let shared = LyricsService()
    
    func searchLyrics(for title: String, artist: String) async -> [LyricLine] {
        // 🚀 模拟在线搜索逻辑 (在此处可以对接真正的 API，如 NeteaseCloudMusic)
        // 为了演示，我们生成一些带时间轴的模拟歌词
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            LyricLine(time: 0, text: "Scanning for lyrics..."),
            LyricLine(time: 5, text: "Found: \(title)"),
            LyricLine(time: 10, text: "Artist: \(artist)"),
            LyricLine(time: 15, text: "This is a skeuomorphic experience."),
            LyricLine(time: 20, text: "Enjoy the vinyl sound."),
            LyricLine(time: 25, text: "Restored by Antigravity."),
            LyricLine(time: 30, text: "--- End of Lyrics ---")
        ]
    }
}
