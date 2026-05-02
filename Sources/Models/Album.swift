import Foundation
import UIKit

struct Track: Identifiable, Equatable {
    // 🚀 核心修复：使用 fileName 作为 ID 确保稳定性，防止视图刷新导致 ID 变更引起的闪退
    var id: String { fileName }
    let title: String
    let artist: String
    let fileName: String
    let duration: String
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

struct Album: Identifiable {
    // 🚀 核心修复：使用 title+artist 作为 ID
    var id: String { title + artist }
    let title: String
    let artist: String
    var coverImage: UIImage?
    let trackCount: Int
    let releaseYear: String
    var tracks: [Track]
}

extension Album {
    static let sampleData: [Album] = [
        Album(
            title: "Random Access Memories",
            artist: "Daft Punk",
            coverImage: nil,
            trackCount: 2,
            releaseYear: "2013",
            tracks: [
                Track(title: "Give Life Back to Music", artist: "Daft Punk", fileName: "sample1", duration: "4:34"),
                Track(title: "The Game of Love", artist: "Daft Punk", fileName: "sample2", duration: "3:52")
            ]
        )
    ]
}
