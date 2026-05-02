import SwiftUI

struct SettingsView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(12)
                        .skeuoRaised(cornerRadius: 12)
                }
                
                Spacer()
                
                Text("SETTINGS")
                    .font(.system(size: 16, weight: .black))
                    .kerning(2)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // Placeholder to balance the header
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // --- 1. Library Section ---
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MUSIC LIBRARY")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 1) {
                            SettingsRow(title: "Media Folders", icon: "folder.fill", value: "\(libraryService.mediaFolders.count) Folders")
                            Divider().background(AppColors.shadowDark.opacity(0.3)).padding(.horizontal)
                            
                            Toggle("Auto Scan Library", isOn: $libraryService.autoScan)
                                .toggleStyle(SkeuoToggleStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                        }
                        .skeuoSunken(cornerRadius: 20)
                    }
                    
                    // --- 2. Playback Section ---
                    VStack(alignment: .leading, spacing: 16) {
                        Text("PLAYBACK")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 1) {
                            Toggle("Parse CUE Sheets", isOn: $libraryService.parseCue)
                                .toggleStyle(SkeuoToggleStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            
                            Divider().background(AppColors.shadowDark.opacity(0.3)).padding(.horizontal)
                            
                            Toggle("Match Lyrics Online", isOn: $libraryService.searchLrc)
                                .toggleStyle(SkeuoToggleStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                        }
                        .skeuoSunken(cornerRadius: 20)
                    }
                    
                    // --- 3. Appearance Section ---
                    VStack(alignment: .leading, spacing: 16) {
                        Text("APPEARANCE")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.leading, 8)
                        
                        HStack {
                            Text("Theme Mode")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            
                            Picker("Theme", selection: $themeManager.currentTheme) {
                                ForEach(AppTheme.allCases, id: \.self) { theme in
                                    Text(theme.rawValue).tag(theme)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 140)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .skeuoSunken(cornerRadius: 20)
                    }
                    
                    // --- 4. Action Section ---
                    Button(action: { libraryService.scanLibrary() }) {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.clockwise.circle.fill")
                            Text("Rescan Library")
                                .font(.system(size: 16, weight: .black))
                            Spacer()
                        }
                        .foregroundColor(AppColors.textActive)
                        .padding(.vertical, 18)
                        .skeuoRaised(cornerRadius: 20)
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 24)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}
