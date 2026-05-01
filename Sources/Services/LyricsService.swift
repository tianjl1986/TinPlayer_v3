import Foundation

// MARK: - 在线歌词服务（LrcLib API）
class LyricsService: ObservableObject {
    static let shared = LyricsService()

    @Published var currentLyrics: [LyricLine] = []
    @Published var isLoading: Bool = false

    private var lastFetched: String = ""
    private init() {}

    // MARK: - 获取歌词
    func fetchLyrics(for song: String, artist: String) {
        let key = "\(song)-\(artist)"
        guard key != lastFetched else { return }
        lastFetched = key
        currentLyrics = []
        isLoading = true

        let songQ = song.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let artistQ = artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlStr = "https://lrclib.net/api/search?track_name=\(songQ)&artist_name=\(artistQ)"

        guard let url = URL(string: urlStr) else {
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            defer { DispatchQueue.main.async { self?.isLoading = false } }
            guard let data = data,
                  let results = try? JSONDecoder().decode([LrcResult].self, from: data),
                  let first = results.first(where: { $0.syncedLyrics != nil }),
                  let lrc = first.syncedLyrics else { return }

            let lines = self?.parseLRC(lrc) ?? []
            DispatchQueue.main.async {
                self?.currentLyrics = lines
            }
        }.resume()
    }

    // MARK: - 解析LRC格式
    private func parseLRC(_ lrc: String) -> [LyricLine] {
        var lines: [LyricLine] = []
        // 支持 [mm:ss.xx] 和 [mm:ss.xxx] 格式
        let pattern = "\\[(\\d+):(\\d+)[\\.,:](\\d+)\\](.*)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        let nsStr = lrc as NSString
        let range = NSRange(location: 0, length: nsStr.length)
        regex.enumerateMatches(in: lrc, range: range) { match, _, _ in
            guard let match = match, match.numberOfRanges == 5 else { return }
            let min = Double(nsStr.substring(with: match.range(at: 1))) ?? 0
            let sec = Double(nsStr.substring(with: match.range(at: 2))) ?? 0
            let ms  = Double(nsStr.substring(with: match.range(at: 3))) ?? 0
            let text = nsStr.substring(with: match.range(at: 4)).trimmingCharacters(in: .whitespaces)

            // ms可能是2位(百毫秒)或3位(毫秒)
            let msDiv = ms < 100 ? 100.0 : 1000.0
            let time = min * 60 + sec + ms / msDiv
            if !text.isEmpty {
                lines.append(LyricLine(text: text, startTime: time))
            }
        }
        return lines.sorted { $0.startTime < $1.startTime }
    }
}

// MARK: - API 响应模型
struct LrcResult: Codable {
    let trackName: String?
    let artistName: String?
    let syncedLyrics: String?
    let plainLyrics: String?
}
