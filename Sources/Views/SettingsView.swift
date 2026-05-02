import SwiftUI
import MediaPlayer

// MARK: - 设置页（1:1 还原 Figma 9904:14861 "Settings - Media Library"）
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var libraryService = MusicLibraryService.shared
    @AppStorage("parseCueSheets") private var parseCueSheets = true
    @AppStorage("searchLrcLyrics") private var searchLrcLyrics = true
    @AppStorage("autoScanOnStartup") private var autoScanOnStartup = false

    var body: some View {
        VStack(spacing: 0) {

            // ── Top Bar（SETTINGS，Inter Bold 14pt）──
            AppHeader(
                title: "SETTINGS".localized,
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("<")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 40, height: 40)
                    }
                )
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // ── Section 1：MEDIA FOLDERS ──
                    SettingsSectionHeader(title: "MEDIA FOLDERS".localized)

                    // 文件夹列表
                    VStack(spacing: 0) {
                        HStack {
                            Text("/storage/emulated/0/Music")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppColors.textPrimary)
                                .lineLimit(1)
                            Spacer()
                            Button(action: {}) {
                                Text("-")
                                    .font(.system(size: 20, weight: .regular))
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(width: 36, height: 36)
                            }
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 48)
                        .background(AppColors.background)
                        .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                        .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)

                    // + Add Folder 按钮
                    Button(action: {}) {
                        HStack {
                            Text("+ Add Folder")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 48)
                        .background(AppColors.background)
                        .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                        .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 24)

                    // ── Section 2：SCANNING OPTIONS ──
                    SettingsSectionHeader(title: "SCANNING OPTIONS".localized)

                    VStack(spacing: 0) {
                        SettingsToggleRow(
                            label: "Parse .cue sheets".localized,
                            isOn: $parseCueSheets
                        )
                        Divider().padding(.leading, 24)
                        SettingsToggleRow(
                            label: "Search for .lrc lyrics".localized,
                            isOn: $searchLrcLyrics
                        )
                        Divider().padding(.leading, 24)
                        SettingsToggleRow(
                            label: "Auto-scan on startup".localized,
                            isOn: $autoScanOnStartup
                        )
                    }
                    .background(AppColors.background)
                    .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                    .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)

                    // ── Section 3：MAINTENANCE ──
                    SettingsSectionHeader(title: "MAINTENANCE".localized)

                    VStack(spacing: 8) {
                        Button(action: { libraryService.requestPermissionAndScan() }) {
                            HStack {
                                Text(libraryService.isScanning ? "Scanning...".localized : "Rescan Now".localized)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 48)
                            .background(AppColors.background)
                            .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                            .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(libraryService.isScanning)

                        Button(action: { libraryService.clearLibrary() }) {
                            HStack {
                                Text("Clear Library".localized)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 48)
                            .background(AppColors.background)
                            .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                            .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 24)

                    // ── Section 4：GENERAL SETTINGS ──
                    SettingsSectionHeader(title: "GENERAL SETTINGS".localized)

                    VStack(spacing: 0) {
                        // 语言切换
                        Button(action: { LocalizationManager.shared.currentLanguage = (LocalizationManager.shared.currentLanguage == .chinese ? .english : .chinese) }) {
                            HStack {
                                Text("Interface Language".localized)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Text(LocalizationManager.shared.currentLanguage.rawValue)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider().padding(.leading, 24)
                        
                        // 主题切换
                        Button(action: { ThemeManager.shared.currentTheme = (ThemeManager.shared.currentTheme == .light ? .dark : .light) }) {
                            HStack {
                                Text("Theme".localized)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Text(ThemeManager.shared.currentTheme.rawValue.localized)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 48)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(AppColors.background)
                    .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                    .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                }
                .padding(.top, 16)
                .padding(.bottom, 48)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

// MARK: - 设置分组标题（Inter Bold 12pt #808080，tracking 2）
struct SettingsSectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(AppColors.textSecondary)
            .tracking(1)
            .padding(.horizontal, 32)
    }
}

// MARK: - Toggle 行（[ ON ] / [ OFF ] 文字样式，按Figma）
struct SettingsToggleRow: View {
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text(isOn ? "[ ON ]" : "[ OFF ]")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .monospacedDigit()
            }
            .padding(.horizontal, 24)
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
