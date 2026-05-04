import Foundation

class LyricsService {
    static let shared = LyricsService()
    
    // LRCLIB API response model
    struct LRCLibResponse: Codable {
        let syncedLyrics: String?
        let plainLyrics: String?
        let artistName: String?
        let trackName: String?
        let duration: Double?
    }
    
    func searchLyrics(for title: String, artist: String, duration: Double? = nil) async -> [LyricLine] {
        let cleanTitle = cleanSearchTerm(title)
        let cleanArtist = cleanSearchTerm(artist)
        
        // 🚀 Strategy 1: Exact match with original metadata
        if let lyrics = await tryExactMatch(artist: artist, title: title, duration: duration) {
            return lyrics
        }
        
        // 🚀 Strategy 2: Exact match with cleaned metadata
        if cleanTitle != title || cleanArtist != artist {
            if let lyrics = await tryExactMatch(artist: cleanArtist, title: cleanTitle, duration: duration) {
                return lyrics
            }
        }
        
        // 🚀 Strategy 3: Search API with cleaned terms + Validation
        let searchUrl = "https://lrclib.net/api/search?q=\(urlEncode(cleanArtist))%20\(urlEncode(cleanTitle))"
        if let lyrics = await fetchLyricsFromSearch(from: searchUrl, targetArtist: cleanArtist, targetTitle: cleanTitle, targetDuration: duration) {
            return lyrics
        }
        
        return [
            LyricLine(text: "Lyrics not found online", startTime: 0),
            LyricLine(text: "Please try manual search in Settings", startTime: 5)
        ]
    }
    
    private func tryExactMatch(artist: String, title: String, duration: Double?) async -> [LyricLine]? {
        var url = "https://lrclib.net/api/get?artist=\(urlEncode(artist))&track_name=\(urlEncode(title))"
        if let dur = duration {
            url += "&duration=\(Int(dur))"
        }
        return await fetchLyrics(from: url)
    }
    
    private func urlEncode(_ string: String) -> String {
        let allowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&+?="))
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }
    
    private func cleanSearchTerm(_ term: String) -> String {
        var cleaned = term
        // Remove common suffixes and parentheticals
        let patterns = [
            "^\\d+[\\s\\.\\-、]*", // 🚀 Remove leading track numbers (e.g., "02 ", "02.", "02-", "02、")
            "\\s*\\(.*?\\)",      // Anything in parentheses
            "\\s*\\[.*?\\]",      // Anything in brackets
            "\\s*-\\s*(Remaster|Remastered|Studio|Single|Explicit|Live).*$", // Common suffixes
            "\\s*feat\\..*$",     // Featured artists
            "\\s*ft\\..*$",       // Featured artists
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
            let response = try JSONDecoder().decode(LRCLibResponse.self, from: data)
            if let synced = response.syncedLyrics {
                return parseLRC(synced)
            } else if let plain = response.plainLyrics {
                return plain.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.enumerated().map { (index, line) in
                    LyricLine(text: line, startTime: Double(index * 5))
                }
            }
        } catch {
            // print("Lyrics exact fetch failed: \(error)")
        }
        return nil
    }
    
    private func fetchLyricsFromSearch(from urlString: String, targetArtist: String, targetTitle: String, targetDuration: Double?) async -> [LyricLine]? {
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let responses = try JSONDecoder().decode([LRCLibResponse].self, from: data)
            
            // 🔍 Smart Filter: Find the best candidate
            let candidate = responses.first { res in
                let artistMatch = res.artistName?.lowercased().contains(targetArtist.lowercased()) ?? false
                let titleMatch = res.trackName?.lowercased().contains(targetTitle.lowercased()) ?? false
                
                var durationMatch = true
                if let targetDur = targetDuration, let resDur = res.duration {
                    durationMatch = abs(targetDur - resDur) < 8.0 // Allow 8s tolerance
                }
                
                return artistMatch && titleMatch && durationMatch
            }
            
            if let bestRes = candidate {
                if let synced = bestRes.syncedLyrics {
                    return parseLRC(synced)
                } else if let plain = bestRes.plainLyrics {
                    return plain.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.enumerated().map { (index, line) in
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
