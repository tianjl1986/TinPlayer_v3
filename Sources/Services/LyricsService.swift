import Foundation

class LyricsService {
    static let shared = LyricsService()
    
    // LRCLIB API response model
    struct LRCLibResponse: Codable {
        let syncedLyrics: String?
        let plainLyrics: String?
    }
    
    func searchLyrics(for title: String, artist: String) async -> [LyricLine] {
        let cleanTitle = cleanSearchTerm(title)
        let cleanArtist = cleanSearchTerm(artist)
        
        // 🚀 Strategy 1: Exact match with original metadata
        if let lyrics = await tryExactMatch(artist: artist, title: title) {
            return lyrics
        }
        
        // 🚀 Strategy 2: Exact match with cleaned metadata (if different)
        if cleanTitle != title || cleanArtist != artist {
            if let lyrics = await tryExactMatch(artist: cleanArtist, title: cleanTitle) {
                return lyrics
            }
        }
        
        // 🚀 Strategy 3: Search API with cleaned terms
        let searchUrl = "https://lrclib.net/api/search?q=\(urlEncode(cleanArtist))%20\(urlEncode(cleanTitle))"
        if let lyrics = await fetchLyricsFromSearch(from: searchUrl) {
            return lyrics
        }
        
        // 🚀 Strategy 4: Search API with only title (Fuzzy fallback)
        let fuzzyUrl = "https://lrclib.net/api/search?track_name=\(urlEncode(cleanTitle))"
        if let lyrics = await fetchLyricsFromSearch(from: fuzzyUrl) {
            return lyrics
        }
        
        return [
            LyricLine(text: "Lyrics not found online", startTime: 0),
            LyricLine(text: "Please try manual search in Settings", startTime: 5)
        ]
    }
    
    private func tryExactMatch(artist: String, title: String) async -> [LyricLine]? {
        let url = "https://lrclib.net/api/get?artist=\(urlEncode(artist))&track_name=\(urlEncode(title))"
        return await fetchLyrics(from: url)
    }
    
    private func urlEncode(_ string: String) -> String {
        let allowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&+"))
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }
    
    private func cleanSearchTerm(_ term: String) -> String {
        var cleaned = term
        // Remove common suffixes and parentheticals
        let patterns = [
            "\\s*\\(.*?\\)",      // Anything in parentheses
            "\\s*\\[.*?\\]",      // Anything in brackets
            "\\s*-\\s*.*$",       // Anything after a dash (e.g., - Remastered)
            "\\s*feat\\..*$",     // Featured artists
            "\\s*ft\\..*$",       // Featured artists
            "\\s+Live\\s*",       // Live tags
            "\\s+Acoustic\\s*",   // Acoustic tags
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: NSRange(location: 0, length: cleaned.utf16.count), withTemplate: "")
            }
        }
        
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? term : cleaned
    }
    
    private func fetchLyrics(from urlString: String) async -> [LyricLine]? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // Debug: print(String(data: data, encoding: .utf8) ?? "")
            let response = try JSONDecoder().decode(LRCLibResponse.self, from: data)
            if let synced = response.syncedLyrics {
                return parseLRC(synced)
            } else if let plain = response.plainLyrics {
                return plain.components(separatedBy: "\n").enumerated().map { (index, line) in
                    LyricLine(text: line, startTime: Double(index * 5))
                }
            }
        } catch {
            print("Lyrics exact fetch failed: \(error)")
        }
        return nil
    }
    
    private func fetchLyricsFromSearch(from urlString: String) async -> [LyricLine]? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let responses = try JSONDecoder().decode([LRCLibResponse].self, from: data)
            // Try to find the first result that has some lyrics
            for response in responses {
                if let synced = response.syncedLyrics {
                    return parseLRC(synced)
                } else if let plain = response.plainLyrics {
                    return plain.components(separatedBy: "\n").enumerated().map { (index, line) in
                        LyricLine(text: line, startTime: Double(index * 5))
                    }
                }
            }
        } catch {
            print("Lyrics search failed: \(error)")
        }
        return nil
    }
    
    private func parseLRC(_ lrc: String) -> [LyricLine] {
        var lines: [LyricLine] = []
        // More robust pattern: [mm:ss], [mm:ss.SS], [mm:ss:SS]
        let pattern = "\\[(\\d+):(\\d+(?:[.:]\\d+)?)\\](.*)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [LyricLine(text: "Regex Error", startTime: 0)]
        }
        
        let nsString = lrc as NSString
        let matches = regex.matches(in: lrc, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            guard match.numberOfRanges >= 4 else { continue }
            
            let minRange = match.range(at: 1)
            let secRange = match.range(at: 2)
            let textRange = match.range(at: 3)
            
            if minRange.location != NSNotFound && secRange.location != NSNotFound && textRange.location != NSNotFound {
                let minStr = nsString.substring(with: minRange)
                let secStr = nsString.substring(with: secRange).replacingOccurrences(of: ":", with: ".")
                let text = nsString.substring(with: textRange).trimmingCharacters(in: .whitespaces)
                
                if let min = Double(minStr), let sec = Double(secStr) {
                    let time = min * 60 + sec
                    lines.append(LyricLine(text: text, startTime: time))
                }
            }
        }
        
        return lines.isEmpty ? [LyricLine(text: "Lyrics format not supported", startTime: 0)] : lines
    }
}
