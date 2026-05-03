import SwiftUI

struct SettingsView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("app_language") private var appLanguage: String = "English"
    @AppStorage("app_theme") private var appTheme: String = "Light"
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header - Standardized
            AppHeader(
                title: appLanguage == "English" ? "SETTINGS" : "设置",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text(appLanguage == "English" ? "DONE" : "完成")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(DesignTokens.textActive)
                    }
                )
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // Section 0: CLASSIFICATION
                    VStack(alignment: .leading, spacing: 12) {
                        Text(appLanguage == "English" ? "CLASSIFICATION" : "分类")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            NavigationLink(destination: LibraryShelfView()) {
                                SkeuoSettingsRow(title: appLanguage == "English" ? "By Album" : "按专辑", value: ">", isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.horizontal, 20)
                            
                            NavigationLink(destination: ArtistListView()) {
                                SkeuoSettingsRow(title: appLanguage == "English" ? "By Artist" : "按歌手", value: ">", isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Section 1: MEDIA LIBRARY
                    VStack(alignment: .leading, spacing: 12) {
                        Text(appLanguage == "English" ? "MEDIA LIBRARY" : "媒体库")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            SkeuoSettingsRow(title: appLanguage == "English" ? "Media Folders" : "媒体文件夹", value: "\(libraryService.mediaFolders.count) \(appLanguage == "English" ? "Folders" : "个文件夹")", showBackground: false)
                            Divider().padding(.horizontal, 20)
                            SkeuoSettingsRow(title: appLanguage == "English" ? "Auto Scan Library" : "自动扫描媒体库", value: "Enabled", isToggle: true, showBackground: false)
                        }
                    }

                    // Section 1.5: APPEARANCE
                    VStack(alignment: .leading, spacing: 12) {
                        Text(appLanguage == "English" ? "APPEARANCE" : "外观")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            Button(action: {
                                appLanguage = (appLanguage == "English" ? "中文" : "English")
                            }) {
                                SkeuoSettingsRow(title: appLanguage == "English" ? "Language" : "语言", value: appLanguage, isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.horizontal, 20)
                            
                            Button(action: {
                                appTheme = (appTheme == "Light" ? "Dark" : "Light")
                            }) {
                                SkeuoSettingsRow(title: appLanguage == "English" ? "Theme" : "主题", value: appTheme, isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Section 2: AUDIO ENGINE
                    VStack(alignment: .leading, spacing: 12) {
                        Text(appLanguage == "English" ? "AUDIO ENGINE" : "音频引擎")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            SkeuoSettingsRow(title: appLanguage == "English" ? "Graphic Equalizer" : "图形均衡器", value: "Flat >", isLink: true, showBackground: false)
                            Divider().padding(.horizontal, 20)
                            SkeuoSettingsRow(title: appLanguage == "English" ? "Resampling Mode" : "重采样模式", value: "SoX High", isLink: true, showBackground: false)
                        }
                    }
                    
                    // Danger Zone
                    Button(action: { /* Reset */ }) {
                        Text(appLanguage == "English" ? "RESET APPLICATION DATA" : "重置应用程序数据")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .skeuoRaised(cornerRadius: 16)
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
        }
        .background(DesignTokens.surfaceLight.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct SkeuoSettingsGroup<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(DesignTokens.surfaceMain)
        .cornerRadius(16)
        .skeuoRaised(cornerRadius: 16)
    }
}

struct SkeuoSettingsRow: View {
    let title: String
    let value: String
    var isToggle: Bool = false
    var isLink: Bool = false
    var showBackground: Bool = true
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DesignTokens.textPrimary)
            
            Spacer()
            
            if isToggle {
                RoundedRectangle(cornerRadius: 14)
                    .fill(DesignTokens.textActive)
                    .frame(width: 44, height: 24)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .padding(2)
                            .offset(x: 10)
                    )
                    .skeuoSunken(cornerRadius: 14)
            } else {
                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14) // 14 + 14 + 20 (approx text height) = 48
        .background(
            Group {
                if showBackground {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DesignTokens.surfaceMain)
                        .skeuoRaised(cornerRadius: 16)
                }
            }
        )
    }
}
