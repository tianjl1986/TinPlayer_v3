import SwiftUI

struct LibraryGridView: View {
    @StateObject private var libraryService = MusicLibraryService.shared
    @StateObject private var player = MusicPlayer.shared
    @Environment(\.presentationMode) var presentationMode
    
    private let columns = [
        GridItem(.fixed(163), spacing: 24),
        GridItem(.fixed(163), spacing: 24)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. 顶部栏 (Raised)
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                }
                
                Spacer()
                
                Text("SKEUOPLAYER")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(DesignTokens.textPrimary)
                
                Spacer()
                
                Button(action: { /* Menu */ }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignTokens.textPrimary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .frame(height: 64)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // 页面标题 (Page Title)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Collection")
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(DesignTokens.textPrimary)
                            .lineSpacing(-4)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "music.note")
                                .font(.system(size: 10))
                            Text("\(libraryService.albums.count) RECORDS IN VAULT")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(DesignTokens.textSecondary)
                    }
                    .padding(.horizontal, 24)
                    
                    // 筛选栏 (Filter Strip)
                    HStack(spacing: 12) {
                        FilterButton(title: "RECENTLY ADDED", isActive: true)
                        FilterButton(title: "ARTISTS", isActive: false)
                        FilterButton(title: "GENRES", isActive: false)
                    }
                    .padding(.horizontal, 24)
                    
                    // 专辑网格 (Album Grid)
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

struct FilterButton: View {
    let title: String
    let isActive: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .black))
            .foregroundColor(isActive ? DesignTokens.textPrimary : DesignTokens.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(DesignTokens.surfaceMain)
                    .skeuoRaised(cornerRadius: 12)
            )
    }
}

struct AlbumCard: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 专辑封面与黑胶唱片 (1:1 Album Art)
            ZStack(alignment: .trailing) {
                // 唱片 (露出一部分)
                Circle()
                    .fill(Color(hexString: "#121212"))
                    .frame(width: 145, height: 145)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .offset(x: 20)
                
                // 唱片封套
                if let cover = album.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 155, height: 155)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .skeuoRaised(cornerRadius: 8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(DesignTokens.surfaceMain)
                        .frame(width: 155, height: 155)
                        .skeuoRaised(cornerRadius: 8)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(DesignTokens.textSecondary)
                        )
                }
            }
            .frame(width: 163, height: 155)
            
            // 专辑信息 (Text Info)
            VStack(alignment: .leading, spacing: 4) {
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
