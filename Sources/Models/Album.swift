import SwiftUI

struct Track: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let duration: String
    let fileName: String // 存储本地绝对路径
}

struct Album: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let coverImageName: String 
    let trackCount: Int
    let releaseYear: String
    var tracks: [Track] = [] 
    
    var coverImage: UIImage? {
        return UIImage(named: coverImageName)
    }
}

extension Album {
    static let sampleData: [Album] = [
        Album(
            title: "11月的萧邦", artist: "周杰伦", coverImageName: "jay_chou_11", trackCount: 12, releaseYear: "2005",
            tracks: [
                Track(title: "夜曲", duration: "03:48", fileName: ""),
                Track(title: "发如雪", duration: "05:01", fileName: ""),
                Track(title: "枫", duration: "04:37", fileName: ""),
                Track(title: "黑色毛衣", duration: "04:11", fileName: ""),
                Track(title: "蓝色风暴", duration: "04:46", fileName: ""),
                Track(title: "浪漫手机", duration: "04:00", fileName: "")
            ]
        ),
        Album(title: "1701", artist: "李志", coverImageName: "lizhi_1701", trackCount: 10, releaseYear: "2014"),
        Album(title: "30", artist: "Adele", coverImageName: "adele_30", trackCount: 12, releaseYear: "2021"),
        Album(title: "F", artist: "李志", coverImageName: "lizhi_f", trackCount: 9, releaseYear: "2011"),
        Album(title: "七里香", artist: "周杰伦", coverImageName: "jay_chou_qilixiang", trackCount: 10, releaseYear: "2004")
    ]
}
