import Foundation
import UIKit

struct Track: Identifiable, Equatable {
    let id: UUID
    let title: String
    let artist: String
    let fileName: String
    let duration: String
    var coverUrl: String = ""
    
    init(id: UUID = UUID(), title: String, artist: String, fileName: String, duration: String, coverUrl: String = "") {
        self.id = id
        self.title = title
        self.artist = artist
        self.fileName = fileName
        self.duration = duration
        self.coverUrl = coverUrl
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        lhs.id == rhs.id
    }
}

struct Album: Identifiable {
    let id: UUID
    let title: String
    let artist: String
    var coverImage: UIImage?
    var coverUrl: String = ""
    let trackCount: Int
    let releaseYear: String
    var tracks: [Track]
    
    init(id: UUID = UUID(), title: String, artist: String, coverImage: UIImage? = nil, coverUrl: String = "", trackCount: Int, releaseYear: String, tracks: [Track]) {
        self.id = id
        self.title = title
        self.artist = artist
        self.coverImage = coverImage
        self.coverUrl = coverUrl
        self.trackCount = trackCount
        self.releaseYear = releaseYear
        self.tracks = tracks
    }
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
