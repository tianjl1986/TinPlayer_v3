import SwiftUI

struct SettingsView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Top Bar - 9904:14862
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("<").font(.system(size: 20, weight: .bold))
                }
                Spacer()
                Text("SETTINGS")
                    .font(.system(size: 16, weight: .black))
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Text("DONE")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(DesignTokens.textActive)
                }
            }
            .foregroundColor(DesignTokens.textPrimary)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 40) {
                    
                    // Section 0: CLASSIFICATION
                    VStack(alignment: .leading, spacing: 16) {
                        Text("CLASSIFICATION")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            NavigationLink(destination: LibraryShelfView()) {
                                SkeuoSettingsRow(title: "By Album", value: ">", isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().padding(.horizontal, 20)
                            
                            NavigationLink(destination: ArtistListView()) {
                                SkeuoSettingsRow(title: "By Artist", value: ">", isLink: true, showBackground: false)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Section 1: MEDIA LIBRARY
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MEDIA LIBRARY")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            SkeuoSettingsRow(title: "Media Folders", value: "\(libraryService.mediaFolders.count) Folders", showBackground: false)
                            Divider().padding(.horizontal, 20)
                            SkeuoSettingsRow(title: "Auto Scan Library", value: "Enabled", isToggle: true, showBackground: false)
                        }
                    }

                    // Section 1.5: APPEARANCE
                    VStack(alignment: .leading, spacing: 16) {
                        Text("APPEARANCE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            SkeuoSettingsRow(title: "Language", value: "English", isLink: true, showBackground: false)
                            Divider().padding(.horizontal, 20)
                            SkeuoSettingsRow(title: "Theme", value: "Light", isLink: true, showBackground: false)
                        }
                    }
                    
                    // Section 2: AUDIO ENGINE
                    VStack(alignment: .leading, spacing: 16) {
                        Text("AUDIO ENGINE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(DesignTokens.textSecondary)
                        
                        SkeuoSettingsGroup {
                            SkeuoSettingsRow(title: "Graphic Equalizer", value: "Flat >", isLink: true, showBackground: false)
                            Divider().padding(.horizontal, 20)
                            SkeuoSettingsRow(title: "Resampling Mode", value: "SoX High", isLink: true, showBackground: false)
                        }
                    }
                    
                    // Danger Zone - 9904:14866
                    Button(action: { /* Reset */ }) {
                        Text("RESET APPLICATION DATA")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .skeuoRaised(cornerRadius: 16)
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 32)
                .padding(.top, 24)
            }
        }
        .background(DesignTokens.surfaceLight.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct SkeuoSettingsGroup<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(DesignTokens.surfaceMain)
        .cornerRadius(16)
        .skeuoRaised(cornerRadius: 16)
    }
}

struct SkeuoSettingsRow: View {
    let title: String
    let value: String
    var isToggle: Bool = false
    var isLink: Bool = false
    var showBackground: Bool = true
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DesignTokens.textPrimary)
            
            Spacer()
            
            if isToggle {
                RoundedRectangle(cornerRadius: 14)
                    .fill(DesignTokens.textActive)
                    .frame(width: 44, height: 24)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .padding(2)
                            .offset(x: 10)
                    )
                    .skeuoSunken(cornerRadius: 14)
            } else {
                Text(value)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14) // 14 + 14 + 20 (approx text height) = 48
        .background(
            Group {
                if showBackground {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DesignTokens.surfaceMain)
                        .skeuoRaised(cornerRadius: 16)
                }
            }
        )
    }
}
