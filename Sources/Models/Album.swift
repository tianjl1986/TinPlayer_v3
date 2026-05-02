import Foundation
import UIKit

struct Track: Identifiable, Equatable {
    var id: String { fileName }
    let title: String
    let artist: String
    let fileName: String
    let duration: String
    var coverUrl: String = "" // Added for 1:1 compatibility
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

struct Album: Identifiable {
    var id: String { title + artist }
    let title: String
    let artist: String
    var coverImage: UIImage?
    var coverUrl: String = "" // Added for 1:1 compatibility
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
