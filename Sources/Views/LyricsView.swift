import SwiftUI

struct LyricsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var player = MusicPlayer.shared
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.down").foregroundColor(.white).font(.title2)
                    }
                    Spacer()
                    Text("LYRICS").font(.headline).foregroundColor(.white)
                    Spacer()
                }.padding()
                
                Spacer()
                
                if let track = player.currentTrack {
                    Text(track.title).font(.title).foregroundColor(.white).padding()
                    Text("Lyrics for this track are currently unavailable.").foregroundColor(.gray)
                } else {
                    Text("No Track Playing").foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
    }
}
