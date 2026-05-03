import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("app_theme") var currentTheme: String = "Light"
    
    var isDark: Bool {
        currentTheme == "Dark"
    }
}
