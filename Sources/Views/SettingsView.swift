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
                        .foregroundColor(AppColors.textActive)
                }
            }
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 40) {
                    
                    // Section 1: MEDIA LIBRARY - 9904:14864
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MEDIA LIBRARY")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(AppColors.textSecondary)
                        
                        VStack(spacing: 12) {
                            SkeuoSettingsRow(title: "Media Folders", value: "\(libraryService.mediaFolders.count) Folders")
                            SkeuoSettingsRow(title: "Auto Scan Library", value: "Enabled", isToggle: true)
                        }
                    }
                    
                    // Section 2: AUDIO ENGINE - 9904:14865
                    VStack(alignment: .leading, spacing: 16) {
                        Text("AUDIO ENGINE")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(AppColors.textSecondary)
                        
                        VStack(spacing: 12) {
                            SkeuoSettingsRow(title: "Graphic Equalizer", value: "Flat >", isLink: true)
                            SkeuoSettingsRow(title: "Resampling Mode", value: "SoX High", isLink: true)
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
        .background(AppColors.surfaceLight.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct SkeuoSettingsRow: View {
    let title: String
    let value: String
    var isToggle: Bool = false
    var isLink: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            if isToggle {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppColors.textActive)
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
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surfaceMain)
                .skeuoRaised(cornerRadius: 16)
        )
    }
}
