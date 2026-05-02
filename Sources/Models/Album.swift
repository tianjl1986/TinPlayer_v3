import Foundation

struct Album: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let coverImage: String // For now, we'll use placeholder names
    let trackCount: Int
    let releaseYear: String
}

extension Album {
    static let sampleData: [Album] = [
        Album(title: "Random Access Memories", artist: "Daft Punk", coverImage: "daft_punk", trackCount: 13, releaseYear: "2013"),
        Album(title: "Discovery", artist: "Daft Punk", coverImage: "discovery", trackCount: 14, releaseYear: "2001"),
        Album(title: "After Hours", artist: "The Weeknd", coverImage: "after_hours", trackCount: 14, releaseYear: "2020"),
        Album(title: "Plastic Beach", artist: "Gorillaz", coverImage: "plastic_beach", trackCount: 16, releaseYear: "2010"),
        Album(title: "Currents", artist: "Tame Impala", coverImage: "currents", trackCount: 13, releaseYear: "2015"),
        Album(title: "Midnights", artist: "Taylor Swift", coverImage: "midnights", trackCount: 13, releaseYear: "2022")
    ]
}
