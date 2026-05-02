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
            // Header - 9897:14822
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                Text("SKEUOPLAYER")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: { /* Menu */ }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .frame(height: 64)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // Page Title - 10411:2198
                    VStack(alignment: .leading, spacing: 8) {
                        Text("My Collection")
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(AppColors.textPrimary)
                            .lineSpacing(-4)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "music.note")
                                .font(.system(size: 10))
                            Text("\(libraryService.albums.count) RECORDS IN VAULT")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal, 24)
                    
                    // Filter Strip - 10411:2210
                    HStack(spacing: 12) {
                        FilterButton(title: "RECENTLY ADDED", isActive: true)
                        FilterButton(title: "ARTISTS", isActive: false)
                        FilterButton(title: "GENRES", isActive: false)
                    }
                    .padding(.horizontal, 24)
                    
                    // Grid - 10411:2220
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
        .background(AppColors.surfaceSecondary.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct FilterButton: View {
    let title: String
    let isActive: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .black))
            .foregroundColor(isActive ? AppColors.textPrimary : AppColors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.surfaceMain)
                    .skeuoRaised(cornerRadius: 12)
            )
    }
}

struct AlbumCard: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 1:1 Record Sleeve + Peeking Record - 10411:2222
            ZStack(alignment: .trailing) {
                // The Record (Peeking Out) - 10411:2223
                Circle()
                    .fill(Color(hex: "#121212"))
                    .frame(width: 145, height: 145)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .offset(x: 20)
                
                // The Sleeve - 10411:2228
                if let cover = album.coverImage {
                    Image(uiImage: cover)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 155, height: 155)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .skeuoRaised(cornerRadius: 8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.surfaceMain)
                        .frame(width: 155, height: 155)
                        .skeuoRaised(cornerRadius: 8)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(AppColors.textSecondary)
                        )
                }
            }
            .frame(width: 163, height: 155)
            
            // Text Info - 10411:2235
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title.uppercased())
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(album.artist.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
        }
    }
}
