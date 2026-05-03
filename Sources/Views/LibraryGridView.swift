import SwiftUI

struct LibraryGridView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Header (Consistency)
            AppHeader(
                title: "COLLECTION",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignTokens.textPrimary)
                    }
                )
            )
            .padding(.horizontal, 24)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Page Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Library")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(DesignTokens.textPrimary)
                        
                        HStack(spacing: 6) {
                            Text("\(libraryService.albums.count) ALBUMS FOUND")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(DesignTokens.textSecondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Album Grid
                    LazyVGrid(columns: columns, spacing: 32) {
                        ForEach(libraryService.albums) { album in
                            NavigationLink(destination: AlbumDetailView(album: album)) {
                                AlbumCard(album: album)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
                .padding(.top, 24)
            }
        }
        .background(DesignTokens.surfaceSecondary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct AlbumCard: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack(alignment: .trailing) {
                // Vinyl Record Detail
                Circle()
                    .fill(Color(hexString: "#111111"))
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .offset(x: 15)
                
                // Album Art
                if let cover = album.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                        .skeuoRaised(cornerRadius: 10)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(DesignTokens.surfaceMain)
                        .frame(width: 150, height: 150)
                        .skeuoRaised(cornerRadius: 10)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title.uppercased())
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                    .lineLimit(1)
                
                Text(album.artist.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(DesignTokens.textSecondary)
                    .lineLimit(1)
            }
        }
    }
}
