import SwiftUI

/// A responsive neumorphic album-art card used by the Now Playing screen.
///
/// The old implementation assembled a turntable from several fixed-size PNGs.
/// Keeping this view asset-light makes it scale correctly on every iPhone size
/// and lets the album artwork remain the visual focus.
struct SquareAlbumArtworkView: View {
    @ObservedObject var player = MusicPlayer.shared
    @ObservedObject var theme = ThemeManager.shared

    var body: some View {
        GeometryReader { geometry in
            let cardSize = min(geometry.size.width, geometry.size.height)
            let outerRadius = max(24, cardSize * 0.09)
            let artworkInset = max(18, cardSize * 0.075)
            let artworkRadius = max(16, cardSize * 0.055)

            ZStack {
                RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
                    .fill(DesignTokens.surfaceMain)
                    .overlay(
                        RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
                            .stroke(DesignTokens.skeuoShadowLight.opacity(theme.isDark ? 0.16 : 0.55), lineWidth: 1)
                    )
                    .skeuoRaised(cornerRadius: outerRadius)

                ZStack {
                    if let cover = player.currentAlbum?.coverImage {
                        Image(uiImage: cover)
                            .resizable()
                            .scaledToFill()
                    } else {
                        DesignTokens.surfaceFlat

                        Image(systemName: "music.note")
                            .font(.system(size: cardSize * 0.18, weight: .medium))
                            .foregroundColor(DesignTokens.textSecondary.opacity(0.28))
                    }
                }
                .frame(
                    width: cardSize - artworkInset * 2,
                    height: cardSize - artworkInset * 2
                )
                .clipShape(RoundedRectangle(cornerRadius: artworkRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: artworkRadius, style: .continuous)
                        .stroke(DesignTokens.skeuoShadowLight.opacity(theme.isDark ? 0.12 : 0.65), lineWidth: 1)
                )
                .shadow(
                    color: Color.black.opacity(theme.isDark ? 0.38 : 0.18),
                    radius: 10,
                    x: 5,
                    y: 7
                )
            }
            .frame(width: cardSize, height: cardSize)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(player.currentAlbum?.title ?? "Album artwork")
    }
}
