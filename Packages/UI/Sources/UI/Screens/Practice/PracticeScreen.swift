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
    @State private var isPrepared = false
    @State private var downloader = MP3Downloader()
    @State private var practiceIndex: Int?
    @State private var moduleName: String?
    
    @State var gobackwardAnimating = false
    @State var goforwardAnimating = false
    
    
    let practice: Practice
    
    var body: some View {
        VStack(alignment: .center) {
            Text(practice.name)
                .font(.title)
            VStack(alignment: .leading) {
                Label(practice.group, systemImage: "ellipsis.bubble")
                Label("Сложность \(practice.complication)/5", systemImage: "brain.head.profile")
                Label(practice.pose, systemImage: "figure.mind.and.body")
            }
            .font(.footnote)
            
            Spacer()
            
            PracticeImage(practice: practice)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
            
            Spacer()
            
            Text(practice.description)
                .lineLimit(4)
                //.minimumScaleFactor(0.3)
                .font(.footnote)
                .fontWeight(.light)
                .foregroundStyle(.secondary)
                .frame(width: 240)
            
            Spacer()
            
            if isLoaded {
                progressBar
                    .padding(.horizontal)
            } else {
                ProgressView() {
                    Text("Загрузка...")
                }
            }
            
            if isLoaded {
                controlButtons
            }
            VStack(spacing: 8) {
                Button(action: {
                    //TODO: залогировать время осознанности!
                    dismiss()
                }) {
                    Text("Завершить")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                Button(action: {
                    dismiss()
                }) {
                    Text("Отменить сессию")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.small)
                .buttonStyle(.plain)
            }
            .frame(width: 240)
            .padding(.top)
            .opacity(audioPlayer.isPlaying || audioPlayer.currentTime == 0 ? 0 : 1)
            //TODO: надо второй критерий поменять. после полного воспроизведения плеер на начало сбрасывается!
        }
        //.ignoresSafeArea()
        //.frame(maxWidth: .infinity)
        .background(
            ZStack {
                Color.black
                    .opacity(0.24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                PracticeImage(practice: practice)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .blur(radius: 54)
            }
        )
        .id(practice.id)
        .navigationTitle(practiceIndex != nil ? "Практика \(practiceIndex!+1)" : "")
        .navigationSubtitle(moduleName != nil ? moduleName! : "")
        .navigationBarTitleDisplayMode(.inline)
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
            guard let mp3Url = try? await currentAccount.fetchAudioUrl(for: practice) else {
                //TODO: выдать сообщение об ошибке.
                print("cant't get mp3Url")
                return
            }
            
            let image = try? await currentAccount.fetchImage(for: practice.image)
            
            print("mp3Url: \(mp3Url.absoluteString)")
            do {
                //let mp3File = try await downloader.downloadMP3IfNeeded(from: mp3Url)
                let mp3File = try await downloader.simpleDownloadMP3(from: mp3Url)
                print("mp3File: \(mp3File.absoluteString)")
                withAnimation {
                    isLoaded = true
                }
                
                try audioPlayer.setupWithMetadata(localFileURL: mp3File, title: practice.name, artist: "Путь великанов", album: practice.group, artwork: image)
                
                print("готов")
                withAnimation {
                    isPrepared = true
                }
            } catch {
                print(error)
            }
            
            currentAccount.currentPractice = practice
        }
        .onDisappear {
            audioPlayer.stop()
            audioPlayer.cleanupCurrentPlayback()
            currentAccount.currentPractice = nil
        }
        .onAppear {
            guard let modules = currentAccount.regular?.data else { return }
            guard let module = modules.first(where: { $0.practicesIDS.contains(practice.id) }) else { return }
            guard let index = module.practicesIDS.firstIndex(of: practice.id) else { return }
            print("\(module.name) \(index)")
            self.practiceIndex = index
            self.moduleName = module.name
        }
    }
    
    @ViewBuilder
    var progressBar: some View {
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
        //.frame(width: 240)
    }
    
    @ViewBuilder
    var controlButtons: some View {
        HStack(spacing: 40) {
            if settingsManager.playerSeekEnabled {
                Button(action: {
                    audioPlayer.seek(to: audioPlayer.currentTime - 15)
                    gobackwardAnimating.toggle()
                }) {
                    Image(systemName: "gobackward.15")
                        .font(.title2)
                        .symbolEffect(.rotate, value: gobackwardAnimating)
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
                    goforwardAnimating.toggle()
                }) {
                    Image(systemName: "goforward.15")
                        .font(.title2)
                        .symbolEffect(.rotate, value: goforwardAnimating)
                }
                .buttonStyle(.glass)
                .glassEffect(.clear, in: .circle)
                .disabled(audioPlayer.currentTime >= audioPlayer.duration)
            }
        }
        .disabled(!isPrepared)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let sign = time < 0 ? "-" : ""
        let minutes = Int(abs(time)) / 60
        let seconds = Int(abs(time)) % 60
        return String(format: "\(sign)%d:%02d", minutes, seconds)
    }
}
