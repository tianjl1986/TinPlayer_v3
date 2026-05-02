import SwiftUI

struct HomeView: View {
    @EnvironmentObject var libraryService: MusicLibraryService
    @EnvironmentObject var musicPlayer: MusicPlayer
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    AppHeader(title: "TIN PLAYER")
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            // 🚀 Top Section: Large Category Entry Buttons
                            HStack(spacing: 24) {
                                NavigationLink(destination: LibraryGridView(filter: .album)) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "square.stack.3d.down.right.fill")
                                            .font(.system(size: 32))
                                        Text("ALBUMS".localized)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                                    .background(AppColors.background)
                                    .skeuoRaised(cornerRadius: 20)
                                    .foregroundColor(AppColors.textPrimary)
                                }
                                
                                NavigationLink(destination: LibraryGridView(filter: .artist)) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 32))
                                        Text("ARTISTS".localized)
                                            .font(.system(size: 14, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                                    .background(AppColors.background)
                                    .skeuoRaised(cornerRadius: 20)
                                    .foregroundColor(AppColors.textPrimary)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            
                            // 🚀 Media Folders Section (Standardized with Home layout)
                            VStack(alignment: .leading, spacing: 12) {
                                Text("MEDIA FOLDERS".localized)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 12) {
                                    ForEach(libraryService.mediaFolders, id: \.self) { folder in
                                        HStack {
                                            Image(systemName: "folder.fill")
                                                .foregroundColor(.orange)
                                            Text(folder)
                                                .font(.system(size: 14))
                                                .lineLimit(1)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(AppColors.background)
                                        .skeuoSunken(cornerRadius: 12)
                                    }
                                    
                                    Button(action: { /* Add Folder Action */ }) {
                                        HStack {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Add Folder".localized)
                                        }
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppColors.background)
                                        .skeuoRaised(cornerRadius: 12)
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            
                            // 🚀 Scan Options Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("SCAN OPTIONS".localized)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 0) {
                                    Toggle("Parse .cue sheets".localized, isOn: $libraryService.parseCue)
                                        .toggleStyle(SkeuoToggleStyle())
                                        .padding()
                                    Divider().padding(.horizontal, 20)
                                    Toggle("Search for .lrc lyrics".localized, isOn: $libraryService.searchLrc)
                                        .toggleStyle(SkeuoToggleStyle())
                                        .padding()
                                }
                                .background(AppColors.background)
                                .skeuoSunken(cornerRadius: 16)
                                .padding(.horizontal, 24)
                            }
                            
                            // 🚀 Maintenance Section
                            VStack(spacing: 12) {
                                Button(action: { libraryService.scanLibrary() }) {
                                    HStack {
                                        Text("Rescan Now".localized)
                                        Spacer()
                                        if libraryService.isScanning { ProgressView() }
                                        else { Image(systemName: "arrow.clockwise") }
                                    }
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding()
                                    .background(AppColors.background)
                                    .skeuoRaised(cornerRadius: 12)
                                }
                                
                                Button(action: { libraryService.clearLibrary() }) {
                                    Text("Clear Library".localized)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppColors.background)
                                        .skeuoRaised(cornerRadius: 12)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // 🚀 App Settings
                            VStack(alignment: .leading, spacing: 12) {
                                Text("GENERAL".localized)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 24)
                                
                                HStack {
                                    Text("Theme".localized)
                                        .font(.system(size: 14))
                                    Spacer()
                                    Picker("", selection: ThemeManager.shared.$currentTheme) {
                                        Text("Light".localized).tag(AppTheme.light)
                                        Text("Dark".localized).tag(AppTheme.dark)
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 150)
                                }
                                .padding()
                                .background(AppColors.background)
                                .skeuoSunken(cornerRadius: 16)
                                .padding(.horizontal, 24)
                            }
                            
                            Spacer(minLength: 120)
                        }
                    }
                }
                
                // 🚀 MiniPlayer Overlay
                VStack {
                    Spacer()
                    MiniPlayerView()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

enum LibraryFilter {
    case album
    case artist
}

extension String {
    var localized: String {
        LocalizationManager.shared.t(self)
    }
}
