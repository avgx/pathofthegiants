import SwiftUI
import AVFoundation
import Env
import Models

struct PracticeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var currentAccount: CurrentAccount
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var audioPlayer: AudioPlayer
    @State private var isLoaded = false
    @State private var downloader = MP3Downloader()
    
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
                    Label(practice.group, systemImage: "ellipsis.bubble")
                    Label("Сложность \(practice.complication)/5", systemImage: "brain.head.profile")
                    Label(practice.pose, systemImage: "figure.mind.and.body")
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
                    .disabled(audioPlayer.duration == 0 || !settingsManager.playerSeekEnabled)
                    
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
                    if settingsManager.playerSeekEnabled {
                        Button(action: {
                            audioPlayer.seek(to: audioPlayer.currentTime - 15)
                        }) {
                            Image(systemName: "gobackward.15")
                                .font(.title2)
                        }
                        .buttonStyle(.glass)
                        .glassEffect(.clear, in: .circle)
                        .disabled(audioPlayer.currentTime <= 0)
                    }
                    
                    Button(action: {
                        audioPlayer.togglePlayPause()
                    }) {
                        Image(systemName: audioPlayer.isPlaying ? "pause" : "play")
                            .font(.title)
                            .padding(8)
                    }
                    .buttonStyle(.glass)
                    .glassEffect(.clear, in: .circle)
                    
                    if settingsManager.playerSeekEnabled {
                        Button(action: {
                            audioPlayer.seek(to: audioPlayer.currentTime + 15)
                        }) {
                            Image(systemName: "goforward.15")
                                .font(.title2)
                        }
                        .buttonStyle(.glass)
                        .glassEffect(.clear, in: .circle)
                        .disabled(audioPlayer.currentTime >= audioPlayer.duration)
                    }
                }
                .disabled(!isLoaded)
            }
            .padding()
        }
        .id(practice.id)
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
            guard let mp3Url = try? await currentAccount.fetchAudioUrl(for: practice) else {
                //TODO: выдать сообщение об ошибке.
                return
            }
            
            let image = try? await currentAccount.fetchImage(for: practice.image)
            
            print("mp3Url: \(mp3Url.absoluteString)")
            do {
                //let mp3File = try await downloader.downloadMP3IfNeeded(from: mp3Url)
                let mp3File = try await downloader.simpleDownloadMP3(from: mp3Url)
                print("mp3File: \(mp3File.absoluteString)")
                
                try audioPlayer.setupWithMetadata(localFileURL: mp3File, title: practice.name, artist: "Путь великанов", album: practice.group, artwork: image)
            } catch {
                print(error)
            }
            
            
            
            //audioPlayer.setupWithMetadata(mp3Data: mp3Data, title: practice.name, artist: "Путь великанов", album: practice.group, artwork: image)
            
            
            isLoaded = true
            
            currentAccount.currentPractice = practice
        }
        .onDisappear {
            audioPlayer.stop()
            audioPlayer.cleanupCurrentPlayback()
            currentAccount.currentPractice = nil
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let sign = time < 0 ? "-" : ""
        let minutes = Int(abs(time)) / 60
        let seconds = Int(abs(time)) % 60
        return String(format: "\(sign)%d:%02d", minutes, seconds)
    }
}
