import Foundation

struct LyricLine: Identifiable {
    let id = UUID()
    let text: String
    let startTime: TimeInterval
}
