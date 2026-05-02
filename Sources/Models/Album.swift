import SwiftUI

// 1. 定义单曲结构体
struct Track: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let duration: String
    let fileName: String
}

// 2. 定义专辑结构体
struct Album: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let coverImageName: String 
    let trackCount: Int
    let releaseYear: String
    var tracks: [Track] = [] // 存储歌曲列表
    
    // 自动加载本地图片的辅助方法
    var coverImage: UIImage? {
        return UIImage(named: coverImageName)
    }
}

// 3. 完整的专辑数据（根据您的截图还原）
extension Album {
    static let sampleData: [Album] = [
        Album(
            title: "11月的萧邦", artist: "周杰伦", coverImageName: "jay_chou_11", trackCount: 12, releaseYear: "2005",
            tracks: [
                Track(title: "夜曲", duration: "03:48", fileName: "nocturne"),
                Track(title: "发如雪", duration: "05:01", fileName: "snow"),
                Track(title: "枫", duration: "04:37", fileName: "maple"),
                Track(title: "黑色毛衣", duration: "04:11", fileName: "sweater"),
                Track(title: "蓝色风暴", duration: "04:46", fileName: "storm"),
                Track(title: "浪漫手机", duration: "04:00", fileName: "phone")
            ]
        ),
        Album(
            title: "1701", artist: "李志", coverImageName: "lizhi_1701", trackCount: 10, releaseYear: "2014",
            tracks: [
                Track(title: "定西", duration: "04:20", fileName: ""),
                Track(title: "热河", duration: "05:30", fileName: "")
            ]
        ),
        Album(
            title: "1984-1989 李宗盛作品集", artist: "李宗盛", coverImageName: "jonathan_1984", trackCount: 15, releaseYear: "1989",
            tracks: [Track(title: "凡人歌", duration: "03:50", fileName: "")]
        ),
        Album(title: "2024 In Tokyo live", artist: "李志", coverImageName: "lizhi_tokyo", trackCount: 18, releaseYear: "2024"),
        Album(title: "30", artist: "Adele", coverImageName: "adele_30", trackCount: 12, releaseYear: "2021"),
        Album(title: "Best Selection Songs CD1", artist: "李志", coverImageName: "lizhi_best1", trackCount: 12, releaseYear: "2018"),
        Album(title: "Best Selection Songs CD2", artist: "李志", coverImageName: "lizhi_best2", trackCount: 12, releaseYear: "2018"),
        Album(title: "F", artist: "李志", coverImageName: "lizhi_f", trackCount: 9, releaseYear: "2011"),
        Album(title: "Jay", artist: "周杰伦", coverImageName: "jay_chou_jay", trackCount: 10, releaseYear: "2000"),
        Album(title: "一番杰作 经典好歌全记录", artist: "王杰", coverImageName: "wangjie_best", trackCount: 16, releaseYear: "1996"),
        Album(title: "七里香", artist: "周杰伦", coverImageName: "jay_chou_qilixiang", trackCount: 10, releaseYear: "2004")
    ]
}
