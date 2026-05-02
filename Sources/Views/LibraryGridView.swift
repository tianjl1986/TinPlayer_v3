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
                
                Text("ALBUMS")
                    .font(.system(size: 16, weight: .black))
                    .kerning(2)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                // View Switcher (Figma 样式)
                Button(action: { /* Switch View */ }) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textActive)
                        .padding(12)
                        .skeuoSunken(cornerRadius: 12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 32) {
                    ForEach(libraryService.albums) { album in
                        NavigationLink(destination: AlbumDetailView(album: album)) {
                            AlbumCard(album: album)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 100)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct AlbumCard: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 拟物化封面容器 (模仿黑胶封套)
            ZStack(alignment: .trailing) {
                // 模拟露出一角的黑胶唱片
                Circle()
                    .fill(Color.black.opacity(0.9))
                    .frame(width: 140, height: 140)
                    .offset(x: 10)
                
                // 专辑封面
                if let cover = album.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 150, height: 150)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.white.opacity(0.3))
                        )
                }
            }
            .skeuoRaised(cornerRadius: 12, radius: 10, offset: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(album.artist)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            .padding(.leading, 4)
        }
    }
}
