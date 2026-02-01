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
    
    //TODO: move to settings
    let glassEffectOnCard = false
    let mergePlayerControlsWithFinishButtons = true
    let practiceCancelButtonEnabled = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            if glassEffectOnCard {
                card
                    .glassEffect(.clear, in: .rect(cornerRadius: 16))
                    .padding(.horizontal)
            }
            else {
                card
                    .padding(.horizontal)
            }
            Spacer()
            
            if mergePlayerControlsWithFinishButtons {
                VStack {
                    playerControls
                    finishButtons
                }
                .padding(.horizontal)
            } else {
                playerControls
                    .padding()
                    .glassEffect(.clear, in: .rect(cornerRadius: 16))
                    .padding(.horizontal)
                
                finishButtons
            }
        }
        .frame(maxWidth: .infinity)
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
                    HapticManager.shared.fireHaptic(.buttonPress)
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
        .task {
            await load()
        }
        .onAppear {
            guard let modules = currentAccount.regular?.data else { return }
            guard let module = modules.first(where: { $0.practicesIDS.contains(practice.id) }) else { return }
            guard let index = module.practicesIDS.firstIndex(of: practice.id) else { return }
            print("\(module.name) \(index)")
            self.practiceIndex = index
            self.moduleName = module.name
            //TODO: practice.image уже точно в кэше. нужно не спрашивать а применять сразу в onAppear
            //let image = try? await currentAccount.fetchImage(for: practice.image)
            
        }
        .onDisappear {
            audioPlayer.stop()
            audioPlayer.cleanupCurrentPlayback()
            currentAccount.cancelPractice()
        }
        .lifecycleLog(String(reflecting: Self.self))
        .lifecycleLog(name: practice.name)
//        .onChange(of: isPrepared) {
//            HapticManager.shared.fireHaptic(.notification(.success))
//        }
    }
    
    @ViewBuilder
    var card: some View {
        VStack(alignment: .center) {
            Text(practice.name)
                .font(.title)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            VStack(alignment: .leading) {
                Label(practice.group, systemImage: "ellipsis.bubble")
                Label("Сложность \(practice.complication)/5", systemImage: "brain.head.profile")
                Label(practice.pose, systemImage: "figure.mind.and.body")
            }
            .font(.footnote)
            
            Spacer()
            
            PracticeImage(practice: practice)
                .frame(width: 240, height: 240)
                .clipShape(Circle())
            
            Spacer()
            
            Text(practice.description)
                .lineLimit(4)
                //.minimumScaleFactor(0.3)
                .font(.footnote)
                .fontWeight(.light)
                .foregroundStyle(.secondary)
                //.frame(width: 240)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
    }
    
    @ViewBuilder
    var playerControls: some View {
        VStack(alignment: .center, spacing: 4) {
            if isLoaded {
                progressBar
                    .foregroundStyle(.white)
            } else {
                ProgressView() {
                    Text("Загрузка...")
                        .frame(maxWidth: .infinity)
                }
            }
            
            if isLoaded {
                controlButtons
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    var finishButtons: some View {
        VStack(spacing: 8) {
            Button(action: {
                currentAccount.closePractice()
                dismiss()
                HapticManager.shared.fireHaptic(.buttonPress)
            }) {
                Text("Завершить")
                    .padding(8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .opacity(audioPlayer.isPlaying || (currentAccount.tracker.currentTotal == 0) ? 0 : 1)
            
            if practiceCancelButtonEnabled {
                Button(action: {
                    currentAccount.cancelPractice()
                    dismiss()
                    HapticManager.shared.fireHaptic(.buttonPress)
                }) {
                    Text("Отменить сессию")
                        .padding(8)
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.small)
                .buttonStyle(.plain)
                .opacity(audioPlayer.isPlaying || (currentAccount.tracker.currentTotal == 0) ? 0 : 1)
            }
        }
        .frame(width: 240)
        .padding(.top)
    }
    
    
    
    @ViewBuilder
    var progressBar: some View {
        HStack {
            Text(formatTime(audioPlayer.currentTime))
                .font(.caption)
            Slider(
                value: Binding(
                    get: { audioPlayer.currentTime },
                    set: { newValue in
                        // Обновляем асинхронно
                        DispatchQueue.main.async {
                            audioPlayer.seek(to: newValue)
                        }
                    }
                ),
                in: 0...audioPlayer.duration
            )
            .sliderThumbVisibility(.hidden)
            .controlSize(.small)
            .tint(.white)
            .disabled(audioPlayer.duration == 0 || !settingsManager.playerSeekEnabled)
            
            Text(formatTime(audioPlayer.currentTime - audioPlayer.duration))
                .font(.caption)
        }
    }
    
    @ViewBuilder
    var controlButtons: some View {
        HStack(spacing: 40) {
            if settingsManager.playerSeekEnabled {
                Button(action: {
                    audioPlayer.seek(to: audioPlayer.currentTime - 15)
                    gobackwardAnimating.toggle()
                    HapticManager.shared.fireHaptic(.buttonPress)
                }) {
                    Image(systemName: "gobackward.15")
                        .font(.title2)
                        .symbolEffect(.rotate, options: .speed(8), value: gobackwardAnimating)
                }
                .disabled(audioPlayer.currentTime <= 0)
            }
            
            Button(action: {
                audioPlayer.togglePlayPause()
                HapticManager.shared.fireHaptic(.buttonPress)
            }) {
                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title)
                    .fontWeight(.bold)
                    .contentTransition(.symbolEffect(.replace))
            }
            .frame(width: 40)
            
            if settingsManager.playerSeekEnabled {
                Button(action: {
                    audioPlayer.seek(to: audioPlayer.currentTime + 15)
                    goforwardAnimating.toggle()
                    HapticManager.shared.fireHaptic(.buttonPress)
                }) {
                    Image(systemName: "goforward.15")
                        .font(.title2)
                        .symbolEffect(.rotate, options: .speed(8), value: goforwardAnimating)
                }
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
    
    @MainActor
    func load() async {
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
            //TODO: конечно токен надо брать "не так". переделать
            let mp3File = try await downloader.simpleDownloadMP3(from: mp3Url, token: AuthToken.load())
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
        
        //currentAccount.currentPractice = practice
        currentAccount.startPractice(practice)
        
        if settingsManager.playerContinueProgress {
            audioPlayer.seek(to: currentAccount.tracker.currentTime)
        }
    }
}
