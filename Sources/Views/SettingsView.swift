import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @EnvironmentObject var libraryService: MusicLibraryService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left").foregroundColor(.white).font(.title3)
                    }
                    Spacer()
                    Text(localizationManager.t("SETTINGS")).font(.system(size: 18, weight: .bold)).foregroundColor(.white).tracking(2)
                    Spacer()
                }.padding(.horizontal, 20).padding(.top, 20)
                
                Form {
                    Section(header: Text("MEDIA FOLDERS").foregroundColor(.gray)) {
                        ForEach(libraryService.mediaFolders, id: \.self) { folder in
                            Text(folder).font(.caption).foregroundColor(.white.opacity(0.6))
                        }
                        Button("+ Add Folder") { /* 这里调起文件夹选择器 */ }.foregroundColor(.blue)
                    }
                    
                    Section(header: Text("SCANNING OPTIONS").foregroundColor(.gray)) {
                        Button(action: { libraryService.scanLibrary() }) {
                            HStack {
                                Text("Rescan Now")
                                Spacer()
                                if libraryService.isScanning { ProgressView() }
                            }
                        }
                    }
                    
                    Section(header: Text("GENERAL SETTINGS").foregroundColor(.gray)) {
                        Picker(localizationManager.t("Interface Language"), selection: $localizationManager.language) {
                            Text("English").tag("en")
                            Text("简体中文").tag("zh")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationBarHidden(true)
    }
}
