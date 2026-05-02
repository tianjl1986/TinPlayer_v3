import SwiftUI

struct Track: Identifiable {
    let id = UUID()
    let title: String
    let duration: String
    let trackNumber: Int
}

struct TrackRow: View {
    let track: Track
    
    var body: some View {
        Button(action: { /* Play this track */ }) {
            HStack(spacing: 20) {
                Text(String(format: "%02d", track.trackNumber))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 28, alignment: .leading)
                
                Text(track.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(track.duration)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(
            Divider()
                .padding(.leading, 68)
                .padding(.trailing, 20)
                .opacity(0.1),
            alignment: .bottom
        )
    }
}

struct AlbumDetailView: View {
    let album: Album
    @Environment(\.presentationMode) var presentationMode
    
    let tracks = [
        Track(title: "Give Life Back to Music", duration: "4:34", trackNumber: 1),
        Track(title: "The Game of Love", duration: "5:22", trackNumber: 2),
        Track(title: "Giorgio by Moroder", duration: "9:04", trackNumber: 3),
        Track(title: "Within", duration: "3:48", trackNumber: 4),
        Track(title: "Instant Crush", duration: "5:37", trackNumber: 5),
        Track(title: "Lose Yourself to Dance", duration: "5:53", trackNumber: 6),
        Track(title: "Touch", duration: "8:18", trackNumber: 7),
        Track(title: "Get Lucky", duration: "6:08", trackNumber: 8)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (Floating Style)
            AppHeader(
                title: "专辑详情",
                leftItem: AnyView(
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(12)
                    }
                ),
                rightItem: AnyView(
                    Button(action: { }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .padding(12)
                    }
                )
            )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Album Big Cover
                    VStack(spacing: 20) {
                        ZStack {
                            if let image = album.coverImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(width: 240, height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .skeuoRaised(cornerRadius: 24)
                        
                        VStack(spacing: 6) {
                            Text(album.title)
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(album.artist)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Play All Button
                    Button(action: { }) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14))
                            Text("PLAY ALL")
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 160, height: 48)
                        .skeuoRaised(cornerRadius: 24)
                    }
                    
                    // Track List Panel
                    VStack(spacing: 0) {
                        ForEach(tracks) { track in
                            TrackRow(track: track)
                        }
                    }
                    .background(AppColors.background)
                    .skeuoSunken(cornerRadius: 24)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumDetailView(album: Album.sampleData[0])
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumDetailView(album: Album.sampleData[0])
    }
}
