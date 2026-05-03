import Foundation
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var language: String = UserDefaults.standard.string(forKey: "app_lang") ?? "en" {
        didSet { UserDefaults.standard.set(language, forKey: "app_lang") }
    }
    
    private let translations: [String: [String: String]] = [
        "en": [
            "MY COLLECTION": "MY COLLECTION",
            "SETTINGS": "SETTINGS",
            "Interface Language": "Language",
            "NOW PLAYING": "NOW PLAYING",
            "ALBUMS": "ALBUMS",
            "Theme": "Theme",
            "Dark": "Dark",
            "Light": "Light",
            "Parse .cue sheets": "Parse .cue sheets",
            "Search for .lrc lyrics": "Search for .lrc lyrics",
            "Auto-scan on startup": "Auto-scan on startup",
            "Rescan Now": "Rescan Now",
            "Clear Library": "Clear Library",
            "MEDIA FOLDERS": "MEDIA FOLDERS",
            "SCANNING OPTIONS": "SCANNING OPTIONS",
            "MAINTENANCE": "MAINTENANCE",
            "GENERAL SETTINGS": "GENERAL SETTINGS",
            "DONE": "DONE",
            "CLASSIFICATION": "CLASSIFICATION",
            "MEDIA LIBRARY": "MEDIA LIBRARY",
            "Folders": "Folders",
            "RESET APPLICATION DATA": "RESET APPLICATION DATA",
            "By Album": "By Album",
            "By Artist": "By Artist"
        ],
        "zh": [
            "MY COLLECTION": "我的收藏",
            "SETTINGS": "设置",
            "Interface Language": "界面语言",
            "NOW PLAYING": "正在播放",
            "ALBUMS": "专辑",
            "Theme": "主题",
            "Dark": "深色",
            "Light": "浅色",
            "Parse .cue sheets": "解析 .cue 分轨",
            "Search for .lrc lyrics": "搜索 .lrc 歌词",
            "Auto-scan on startup": "启动时自动扫描",
            "Rescan Now": "立即重新扫描",
            "Clear Library": "清空媒体库",
            "MEDIA FOLDERS": "媒体文件夹",
            "SCANNING OPTIONS": "扫描选项",
            "MAINTENANCE": "维护",
            "GENERAL SETTINGS": "常规设置",
            "DONE": "完成",
            "CLASSIFICATION": "分类",
            "MEDIA LIBRARY": "媒体库",
            "Folders": "个文件夹",
            "RESET APPLICATION DATA": "重置应用程序数据",
            "By Album": "按专辑",
            "By Artist": "按艺术家"
        ]
    ]
    
    func t(_ key: String) -> String {
        return translations[language]?[key] ?? key
    }
}

// 🚀 修复：增加 String 扩展，支持原有代码中的 .localized 写法
extension String {
    var localized: String {
        return LocalizationManager.shared.t(self)
    }
}
