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
                title: "SETTINGS",
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

                    // ── Section 1：MEDIA FOLDERS（Inter Bold 12pt #808080）──
                    SettingsSectionHeader(title: "MEDIA FOLDERS")

                    // 文件夹列表（Figma：白色卡片，14pt Regular，右侧 - 按钮）
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

                    // + Add Folder 按钮（粗体）
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
                    SettingsSectionHeader(title: "SCANNING OPTIONS")

                    VStack(spacing: 0) {
                        SettingsToggleRow(
                            label: "Parse .cue sheets",
                            isOn: $parseCueSheets
                        )
                        Divider().padding(.leading, 24)
                        SettingsToggleRow(
                            label: "Search for .lrc lyrics",
                            isOn: $searchLrcLyrics
                        )
                        Divider().padding(.leading, 24)
                        SettingsToggleRow(
                            label: "Auto-scan on startup",
                            isOn: $autoScanOnStartup
                        )
                    }
                    .background(AppColors.background)
                    .shadow(color: AppColors.shadowLight, radius: 4, x: -2, y: -2)
                    .shadow(color: AppColors.shadowDark, radius: 4, x: 2, y: 2)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)

                    // ── Section 3：MAINTENANCE ──
                    SettingsSectionHeader(title: "MAINTENANCE")

                    VStack(spacing: 8) {
                        // Rescan Now 按钮
                        Button(action: { libraryService.requestPermissionAndScan() }) {
                            HStack {
                                Text(libraryService.isScanning ? "Scanning..." : "Rescan Now")
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

                        // Clear Library 按钮
                        Button(action: { libraryService.clearLibrary() }) {
                            HStack {
                                Text("Clear Library")
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
                    SettingsSectionHeader(title: "GENERAL SETTINGS")

                    VStack(spacing: 0) {
                        HStack {
                            Text("Interface Language")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Text("English")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.horizontal, 24)
                        .frame(height: 48)
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
