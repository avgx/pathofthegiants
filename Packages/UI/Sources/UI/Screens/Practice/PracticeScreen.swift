import SwiftUI
import AVFoundation
import Env
import Models

struct PracticeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentAccount: CurrentAccount
    
    @StateObject private var audioPlayer = AudioPlayer.shared
    @State private var isLoaded = false
    
    let practice: Practice
    
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
                    .fontWeight(.light)
                    .foregroundStyle(.secondary)
                    .frame(width: 200)

                // Progress bar
                VStack {
                    Slider(
                        value: Binding(
                            get: { audioPlayer.currentTime },
                            set: { audioPlayer.seek(to: $0) }
                        ),
                        in: 0...audioPlayer.duration
                    )
                    .disabled(audioPlayer.duration == 0)
                    
                    HStack {
                        Text(formatTime(audioPlayer.currentTime))
                            .font(.caption)
                        Spacer()
                        Text(formatTime(audioPlayer.currentTime - audioPlayer.duration))
                            .font(.caption)
                    }
                }
                .frame(width: 240)
                
                // Control buttons
                HStack(spacing: 40) {
                    Button(action: {
                        audioPlayer.seek(to: audioPlayer.currentTime - 15)
                    }) {
                        Image(systemName: "gobackward.15")
                            .font(.title2)
                    }
                    .disabled(audioPlayer.currentTime <= 0)
                    
                    Button(action: {
                        audioPlayer.togglePlayPause()
                    }) {
                        Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 50))
                    }
                    
                    
                    Button(action: {
                        audioPlayer.seek(to: audioPlayer.currentTime + 15)
                    }) {
                        Image(systemName: "goforward.15")
                            .font(.title2)
                    }
                    .disabled(audioPlayer.currentTime >= audioPlayer.duration)
                }
                .disabled(!isLoaded)
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
            guard !isLoaded else { return }
            guard let mp3Data = try? await currentAccount.fetchAudio(for: practice) else {
                //TODO: выдать сообщение об ошибке.
                return
            }
            
            let image = try? await currentAccount.fetchImage(for: practice.image)
            
            audioPlayer.setupWithMetadata(mp3Data: mp3Data, title: practice.name, artist: "Путь великанов", album: practice.group, artwork: image)

            isLoaded = true
            
            audioPlayer.play()
        }
        .onDisappear {
            audioPlayer.stop()
            audioPlayer.cleanupCurrentPlayback()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(abs(time)) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
