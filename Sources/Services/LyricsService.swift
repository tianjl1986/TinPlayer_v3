import Foundation

class LyricsService {
    static let shared = LyricsService()
    
    func searchLyrics(for title: String, artist: String) async -> [LyricLine] {
        // 🚀 模拟在线搜索逻辑 (在此处可以对接真正的 API，如 NeteaseCloudMusic)
        // 为了演示，我们生成一些带时间轴的模拟歌词
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        return [
            LyricLine(text: "Scanning for lyrics...", startTime: 0),
            LyricLine(text: "Found: \(title)", startTime: 5),
            LyricLine(text: "Artist: \(artist)", startTime: 10),
            LyricLine(text: "This is a skeuomorphic experience.", startTime: 15),
            LyricLine(text: "Enjoy the vinyl sound.", startTime: 20),
            LyricLine(text: "Restored by Antigravity.", startTime: 25),
            LyricLine(text: "--- End of Lyrics ---", startTime: 30)
        ]
    }
}
