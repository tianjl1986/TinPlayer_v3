import SwiftUI

// MARK: - SkeuoSettingsGroup
struct SkeuoSettingsGroup<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(DesignTokens.surfaceLight)
        .cornerRadius(16)
        .skeuoSunken(cornerRadius: 16)
    }
}

// MARK: - SkeuoSettingsRow
struct SkeuoSettingsRow: View {
    let title: String
    var value: String = ""
    var isLink: Bool = false
    var isToggle: Bool = false
    var showBackground: Bool = true
    @State private var isOn = true
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(DesignTokens.textPrimary)
            
            Spacer()
            
            if isToggle {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: DesignTokens.textActive))
            } else {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isLink ? DesignTokens.textActive : DesignTokens.textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(showBackground ? DesignTokens.surfaceLight : Color.clear)
    }
}

// MARK: - AlbumCard
struct AlbumCard: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                if let cover = album.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 140)
                        .cornerRadius(16)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DesignTokens.surfaceMain)
                        .frame(width: 140, height: 140)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 40))
                                .foregroundColor(DesignTokens.textSecondary.opacity(0.1))
                        )
                }
            }
            .skeuoRaised(cornerRadius: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                    .lineLimit(1)
                
                Text(album.artist)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 140)
    }
}

// MARK: - TypewriterText
struct TypewriterText: View {
    let text: String
    let isCurrent: Bool
    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @State private var timer: Timer?
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Text(displayedText)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(isCurrent ? DesignTokens.textPrimary : DesignTokens.textSecondary.opacity(0.4))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            if isCurrent && currentIndex < text.count {
                Rectangle()
                    .fill(DesignTokens.textActive)
                    .frame(width: 2, height: 22)
                    .opacity(0.8)
            }
            
            Spacer(minLength: 0)
        }
        .onAppear {
            if isCurrent {
                startTypewriter()
            } else {
                displayedText = text
            }
        }
        .onChange(of: isCurrent) { newValue in
            if newValue {
                startTypewriter()
            } else {
                // If it was already typing, stop it and show full
                stopTypewriter()
                displayedText = text
            }
        }
    }
    
    private func startTypewriter() {
        stopTypewriter()
        displayedText = ""
        currentIndex = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText.append(text[index])
                currentIndex += 1
            } else {
                stopTypewriter()
            }
        }
    }
    
    private func stopTypewriter() {
        timer?.invalidate()
        timer = nil
    }
}

