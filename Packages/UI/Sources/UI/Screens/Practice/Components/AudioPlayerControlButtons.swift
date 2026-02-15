import SwiftUI
import Env
import Models

struct AudioPlayerControlButtons: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var audioPlayer: AudioPlayer
    @State var gobackwardAnimating = false
    @State var goforwardAnimating = false
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges() // Place it here
#endif
        controlButtons
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
        
    }
}
