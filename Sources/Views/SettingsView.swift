import SwiftUI

struct SettingsView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @ObservedObject private var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var theme = ThemeManager.shared
    @AppStorage("app_theme") private var appTheme: String = "Light"
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header - Standardized
            AppHeader(
                title: loc.t("SETTINGS"),
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text(loc.t("DONE"))
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(DesignTokens.textActive)
                    }
                )
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // Section: CLASSIFICATION
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.t("CLASSIFICATION"))
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            NavigationLink(destination: LibraryShelfView()) {
                                SkeuoSettingsRow(title: loc.t("By Album"), value: ">", isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.horizontal, 20)
                            
                            NavigationLink(destination: ArtistListView()) {
                                SkeuoSettingsRow(title: loc.t("By Artist"), value: ">", isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Section: MEDIA LIBRARY
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.t("MEDIA LIBRARY"))
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            SkeuoSettingsRow(title: loc.t("Media Folders"), value: "\(libraryService.mediaFolders.count) \(loc.t("Folders"))", showBackground: false)
                            Divider().padding(.horizontal, 20)
                            SkeuoSettingsRow(title: loc.t("Auto-scan on startup"), value: "Enabled", isToggle: true, showBackground: false)
                        }
                    }

                    // Section: APPEARANCE
                    VStack(alignment: .leading, spacing: 12) {
                        Text(loc.t("GENERAL SETTINGS"))
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            Button(action: {
                                loc.language = (loc.language == "en" ? "zh" : "en")
                            }) {
                                SkeuoSettingsRow(title: loc.t("Interface Language"), value: loc.language == "en" ? "English" : "中文", isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.horizontal, 20)
                            
                            Button(action: {
                                theme.currentTheme = (theme.currentTheme == "Light" ? "Dark" : "Light")
                            }) {
                                SkeuoSettingsRow(title: loc.t("Theme"), value: loc.t(theme.currentTheme), isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Danger Zone
                    Button(action: { /* Reset */ }) {
                        Text(loc.t("RESET APPLICATION DATA"))
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


