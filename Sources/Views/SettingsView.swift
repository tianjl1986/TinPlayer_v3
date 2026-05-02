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
                    Section(header: Text("MEDIA FOLDERS").foregroundColor(AppColors.textSecondary)) {
                        ForEach(libraryService.mediaFolders, id: \.self) { folder in
                            Text(folder).font(.caption).foregroundColor(AppColors.textSecondary)
                        }
                        Button("+ Add Folder") { /* Logic */ }.foregroundColor(.blue)
                    }
                    
                    Section(header: Text("SCANNING OPTIONS").foregroundColor(AppColors.textSecondary)) {
                        Button(action: { libraryService.scanLibrary() }) {
                            HStack {
                                Text("Rescan Now").foregroundColor(AppColors.textPrimary)
                                Spacer()
                                if libraryService.isScanning { ProgressView() }
                            }
                        }
                    }
                    
                    Section(header: Text("GENERAL SETTINGS").foregroundColor(AppColors.textSecondary)) {
                        Picker(LocalizationManager.shared.t("Interface Language"), selection: $localizationManager.language) {
                            Text("English").tag("en")
                            Text("简体中文").tag("zh")
                        }
                        .foregroundColor(AppColors.textPrimary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarHidden(true)
    }
}
