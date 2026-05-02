import SwiftUI

struct SettingsView: View {
    @ObservedObject var localizationManager = LocalizationManager.shared
    @EnvironmentObject var libraryService: MusicLibraryService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                AppHeader(
                    title: "SETTINGS".localized,
                    leftItem: AnyView(
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20))
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 40, height: 40)
                        }
                    )
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 🚀 扫描选项组
                        VStack(spacing: 0) {
                            toggleRow("Parse .cue sheets".localized, isOn: $libraryService.parseCue)
                            Divider().padding(.leading, 20).background(AppColors.separator)
                            toggleRow("Search for .lrc lyrics".localized, isOn: $libraryService.searchLrc)
                            Divider().padding(.leading, 20).background(AppColors.separator)
                            toggleRow("Auto-scan on startup".localized, isOn: $libraryService.autoScan)
                        }
                        .background(AppColors.background)
                        .skeuoSunken(cornerRadius: 16)
                        .padding(.horizontal, 20)
                        
                        // 🚀 操作按钮组
                        VStack(spacing: 12) {
                            Button(action: { libraryService.scanLibrary() }) {
                                HStack {
                                    Text("Rescan Now".localized)
                                    Spacer()
                                    if libraryService.isScanning { ProgressView() }
                                    else { Image(systemName: "arrow.clockwise") }
                                }
                                .foregroundColor(AppColors.textPrimary)
                                .padding()
                                .background(AppColors.background)
                                .skeuoRaised(cornerRadius: 12)
                            }
                            
                            Button(action: { libraryService.clearLibrary() }) {
                                Text("Clear Library".localized)
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.background)
                                    .skeuoRaised(cornerRadius: 12)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 🚀 主题与语言
                        VStack(spacing: 20) {
                            HStack {
                                Text("Theme".localized)
                                Spacer()
                                Picker("", selection: ThemeManager.shared.$currentTheme) {
                                    Text("Light".localized).tag(AppTheme.light)
                                    Text("Dark".localized).tag(AppTheme.dark)
                                }
                                .pickerStyle(.segmented)
                                .frame(width: 150)
                            }
                        }
                        .padding(20)
                        .background(AppColors.background)
                        .skeuoSunken(cornerRadius: 16)
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 24)
                }
            }
        }
    }
    
    private func toggleRow(_ title: String, isOn: Binding<Bool>) -> some View {
        Toggle(title, isOn: isOn)
            .toggleStyle(SkeuoToggleStyle())
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
    }
}
