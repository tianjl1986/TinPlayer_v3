import SwiftUI

struct SettingsView: View {
    @ObservedObject var localizationManager = LocalizationManager.shared
    @EnvironmentObject var libraryService: MusicLibraryService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppColors.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.textPrimary)
                            .font(.title3)
                    }
                    Spacer()
                    Text(LocalizationManager.shared.t("SETTINGS"))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .tracking(2)
                    Spacer()
                }.padding(.horizontal, 20).padding(.top, 20)
                
                Form {
                    Section(header: Text("MEDIA FOLDERS".localized).foregroundColor(AppColors.textSecondary)) {
                        ForEach(libraryService.mediaFolders, id: \.self) { folder in
                            Text(folder).font(.caption).foregroundColor(AppColors.textSecondary)
                        }
                        Button("+ Add Folder") { /* Logic */ }.foregroundColor(.blue)
                    }
                    
                    Section(header: Text("SCANNING OPTIONS".localized).foregroundColor(AppColors.textSecondary)) {
                        Toggle("Parse .cue sheets".localized, isOn: $libraryService.parseCue)
                        Toggle("Search for .lrc lyrics".localized, isOn: $libraryService.searchLrc)
                        Toggle("Auto-scan on startup".localized, isOn: $libraryService.autoScan)
                    }
                    
                    Section(header: Text("MAINTENANCE".localized).foregroundColor(AppColors.textSecondary)) {
                        Button(action: { libraryService.scanLibrary() }) {
                            HStack {
                                Text("Rescan Now".localized).foregroundColor(AppColors.textPrimary)
                                Spacer()
                                if libraryService.isScanning { ProgressView() }
                            }
                        }
                        Button(action: { libraryService.clearLibrary() }) {
                            Text("Clear Library".localized).foregroundColor(.red)
                        }
                    }
                    
                    Section(header: Text("GENERAL SETTINGS".localized).foregroundColor(AppColors.textSecondary)) {
                        Picker("Interface Language".localized, selection: $localizationManager.language) {
                            Text("English").tag("en")
                            Text("简体中文").tag("zh")
                        }
                        
                        Picker("Theme".localized, selection: ThemeManager.shared.$currentTheme) {
                            Text("Light".localized).tag(AppTheme.light)
                            Text("Dark".localized).tag(AppTheme.dark)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarHidden(true)
    }
}
