import Foundation

class LyricsService {
    static let shared = LyricsService()
    
    // LRCLIB API response model
    struct LRCLibResponse: Codable {
        let syncedLyrics: String?
        let plainLyrics: String?
    }
    
    func searchLyrics(for title: String, artist: String) async -> [LyricLine] {
        let titleEscaped = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let artistEscaped = artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://lrclib.net/api/get?artist=\(artistEscaped)&track_name=\(titleEscaped)"
        
        guard let url = URL(string: urlString) else {
            return [LyricLine(text: "Invalid URL", startTime: 0)]
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(LRCLibResponse.self, from: data)
            
            if let synced = response.syncedLyrics {
                return parseLRC(synced)
            } else if let plain = response.plainLyrics {
                return plain.components(separatedBy: "\n").enumerated().map { (index, line) in
                    LyricLine(text: line, startTime: Double(index * 5))
                }
            }
        } catch {
            print("Lyrics fetch error: \(error)")
        }
        
        // Fallback mock lyrics if fetch fails
        return [
            LyricLine(text: "Lyrics not found online", startTime: 0),
            LyricLine(text: "Please check your network connection", startTime: 5),
            LyricLine(text: "---", startTime: 10)
        ]
    }
    
    private func parseLRC(_ lrc: String) -> [LyricLine] {
        var lines: [LyricLine] = []
        let pattern = "\\[(\\d+):(\\d+\\.\\d+)\\](.*)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        let nsString = lrc as NSString
        let matches = regex?.matches(in: lrc, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
        
        for match in matches {
            let minStr = nsString.substring(with: match.range(at: 1))
            let secStr = nsString.substring(with: match.range(at: 2))
            let text = nsString.substring(with: match.range(at: 3)).trimmingCharacters(in: .whitespaces)
            
            if let min = Double(minStr), let sec = Double(secStr) {
                let time = min * 60 + sec
                lines.append(LyricLine(text: text, startTime: time))
            }
        }
        
        return lines.isEmpty ? [LyricLine(text: "Error parsing lyrics", startTime: 0)] : lines
    }
}
