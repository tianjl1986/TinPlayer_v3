import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var localizationManager = LocalizationManager.shared
    @EnvironmentObject var libraryService: MusicLibraryService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            themeManager.background.ignoresSafeArea()
            VStack(spacing: 0) {
                AppHeader(
                    title: localizationManager.t("SETTINGS"),
                    leftItem: AnyView(
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                                .frame(width: 40, height: 40)
                        }
                    )
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 🚀 扫描选项组
                        VStack(spacing: 0) {
                            toggleRow(localizationManager.t("Parse .cue sheets"), isOn: $libraryService.parseCue)
                            Divider().padding(.leading, 20).opacity(0.1)
                            toggleRow(localizationManager.t("Search for .lrc lyrics"), isOn: $libraryService.searchLrc)
                            Divider().padding(.leading, 20).opacity(0.1)
                            toggleRow(localizationManager.t("Auto-scan on startup"), isOn: $libraryService.autoScan)
                        }
                        .background(themeManager.background)
                        .skeuoSunken(cornerRadius: 16)
                        .padding(.horizontal, 20)
                        
                        // 🚀 操作按钮组
                        VStack(spacing: 12) {
                            Button(action: { libraryService.scanLibrary() }) {
                                HStack {
                                    Text(localizationManager.t("Rescan Now"))
                                    Spacer()
                                    if libraryService.isScanning { ProgressView() }
                                    else { Image(systemName: "arrow.clockwise") }
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(themeManager.textPrimary)
                                .padding()
                                .background(themeManager.background)
                                .skeuoRaised(cornerRadius: 12)
                            }
                            
                            Button(action: { libraryService.clearLibrary() }) {
                                Text(localizationManager.t("Clear Library"))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(themeManager.background)
                                    .skeuoRaised(cornerRadius: 12)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 🚀 主题与语言
                        VStack(spacing: 20) {
                            HStack {
                                Text(localizationManager.t("Theme"))
                                    .font(.system(size: 14, weight: .medium))
                                Spacer()
                                Picker("", selection: $themeManager.currentTheme) {
                                    Text(localizationManager.t("Light")).tag(AppTheme.light)
                                    Text(localizationManager.t("Dark")).tag(AppTheme.dark)
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 150)
                            }
                        }
                        .padding(20)
                        .background(themeManager.background)
                        .skeuoSunken(cornerRadius: 16)
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 24)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .toggleStyle(SkeuoToggleStyle())
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
    }
}
