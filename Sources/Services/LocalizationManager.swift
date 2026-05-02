import Foundation

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    @Published var language: String = UserDefaults.standard.string(forKey: "app_lang") ?? "en" {
        didSet { UserDefaults.standard.set(language, forKey: "app_lang") }
    }
    
    private let translations = [
        "en": [
            "MY COLLECTION": "MY COLLECTION",
            "SETTINGS": "SETTINGS",
            "Interface Language": "Language",
            "NOW PLAYING": "NOW PLAYING",
            "ALBUMS": "ALBUMS"
        ],
        "zh": [
            "MY COLLECTION": "我的收藏",
            "SETTINGS": "设置",
            "Interface Language": "界面语言",
            "NOW PLAYING": "正在播放",
            "ALBUMS": "专辑"
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
