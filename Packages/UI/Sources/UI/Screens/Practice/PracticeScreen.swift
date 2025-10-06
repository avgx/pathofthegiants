import SwiftUI
import AVFoundation
import Env
import Models

struct PracticeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let practice: Practice
    
    @State private var isPlaying = false
    @State private var refreshTime = UUID()
    
    func togglePlayPause() {
        if isPlaying {
            AudioPlayer.shared.pause()
        } else {
            AudioPlayer.shared.play()
        }
        isPlaying.toggle()
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            PracticeImage(practice: practice)
                .aspectRatio(contentMode: .fill)
                .blur(radius: 12)
                .opacity(0.33)
            
            PracticeImage(practice: practice)
                .frame(width: 160, height: 160)
            
            VStack {
                Text(practice.name)
                    .font(.title)
                VStack {
                    Text(practice.group)
                    Text("Сложность \(practice.complication)/5")
                    Text(practice.pose)
                }
                .font(.footnote)
                
                Spacer()
                
                Text(practice.description)
                    .lineLimit(4)
                    .minimumScaleFactor(0.3)
                    .font(.footnote)
                    .frame(width: 200)
                
                VStack {
                    let current = AudioPlayer.shared.currentTime ?? 0
                    let total = AudioPlayer.shared.duration ?? 0
                    ProgressView(value: current, total: total)
                    HStack {
                        Text("\(Int(current))")
                        Spacer()
                        Text("\(Int(total))")
                    }
                    .font(.footnote)
                }
                .id(refreshTime)
                .frame(width: 240)
                .task(id: refreshTime) {
                    try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
                    refreshTime = UUID()
                }
                .padding()
                
                Button(action: togglePlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                .padding()
                .background(
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 100, height: 100)
                )
                
            }
            .padding()
        }
        //.ignoresSafeArea()
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
        .task { @MainActor in
            guard let mp3Data = try? await currentAccount.fetchAudio(for: practice) else {
                //TODO: disable
                return
            }
            
            AudioPlayer.shared.setup(mp3Data: mp3Data)
            //TODO: обновить currentTime и duration
            print(AudioPlayer.shared.duration)
            
            togglePlayPause()
        }
        .onDisappear {
            AudioPlayer.shared.stop()
        }
    }
    
}
