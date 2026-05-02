import Foundation
import UIKit

struct Track: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let artist: String  // 🚀 补全：修复 NowPlayingView 报错所需的 artist 属性
    let fileName: String
    let duration: String
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

struct Album: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let coverImage: UIImage?
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
                Track(title: "Give Life Back to Music", artist: "Daft Punk", fileName: "", duration: "4:34"),
                Track(title: "The Game of Love", artist: "Daft Punk", fileName: "", duration: "3:52")
            ]
        )
    ]
}
