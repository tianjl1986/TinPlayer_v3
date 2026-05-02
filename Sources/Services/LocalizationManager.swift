import SwiftUI

// MARK: - 语言模式
enum AppLanguage: String, CaseIterable {
    case chinese = "简体中文"
    case english = "English"
    
    var code: String {
        switch self {
        case .chinese: return "zh-Hans"
        case .english: return "en"
        }
    }
}

// MARK: - 本地化管理
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("appLanguage") var currentLanguage: AppLanguage = .chinese
    
    private let translations: [String: [String: String]] = [
        "SETTINGS": ["zh-Hans": "设置", "en": "SETTINGS"],
        "MEDIA FOLDERS": ["zh-Hans": "媒体文件夹", "en": "MEDIA FOLDERS"],
        "SCANNING OPTIONS": ["zh-Hans": "扫描选项", "en": "SCANNING OPTIONS"],
        "MAINTENANCE": ["zh-Hans": "维护", "en": "MAINTENANCE"],
        "GENERAL SETTINGS": ["zh-Hans": "常规设置", "en": "GENERAL SETTINGS"],
        "Parse .cue sheets": ["zh-Hans": "解析 .cue 文件", "en": "Parse .cue sheets"],
        "Search for .lrc lyrics": ["zh-Hans": "搜索 .lrc 歌词", "en": "Search for .lrc lyrics"],
        "Auto-scan on startup": ["zh-Hans": "启动时自动扫描", "en": "Auto-scan on startup"],
        "Rescan Now": ["zh-Hans": "立即扫描", "en": "Rescan Now"],
        "Scanning...": ["zh-Hans": "正在扫描...", "en": "Scanning..."],
        "Clear Library": ["zh-Hans": "清空媒体库", "en": "Clear Library"],
        "Interface Language": ["zh-Hans": "界面语言", "en": "Interface Language"],
        "Theme": ["zh-Hans": "主题模式", "en": "Theme"],
        "Light": ["zh-Hans": "浅色", "en": "Light"],
        "Dark": ["zh-Hans": "深色", "en": "Dark"],
        "LIBRARY": ["zh-Hans": "音乐库", "en": "LIBRARY"],
        "ALBUMS": ["zh-Hans": "专辑", "en": "ALBUMS"],
        "TRACKS": ["zh-Hans": "曲目", "en": "TRACKS"],
        "PLAYING": ["zh-Hans": "正在播放", "en": "PLAYING"]
    ]
    
    func localizedString(_ key: String) -> String {
        return translations[key]?[currentLanguage.code] ?? key
    }
}

// MARK: - String 扩展
extension String {
    var localized: String {
        LocalizationManager.shared.localizedString(self)
    }
}
