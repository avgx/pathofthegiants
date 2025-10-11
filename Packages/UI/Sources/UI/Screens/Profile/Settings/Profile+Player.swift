import SwiftUI
import Env

extension Profile {
    struct PlayerView: View {
        @EnvironmentObject var settingsManager: SettingsManager
        
//        @State var trackProgress = false
        
        var body: some View {
            List {
                Section {
                    Toggle("Перемотка", isOn: $settingsManager.playerSeekEnabled)
//                    Toggle("Сохранять прогресс", isOn: $trackProgress)
                }
            }
        }
    }
}
