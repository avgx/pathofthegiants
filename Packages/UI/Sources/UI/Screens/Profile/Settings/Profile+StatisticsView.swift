import SwiftUI
import Env

extension Profile {
    struct StatisticsView: View {
        @EnvironmentObject var settingsManager: SettingsManager
        
        var body: some View {
            List {
                Section {
                    Picker("Учитывать", systemImage: "clock", selection: $settingsManager.statisticsUpdate) {
                        ForEach(SettingsManager.StatisticsUpdate.allCases) { x in
                            Text(x.description).tag(x)
                        }
                    }                    
                } header: {
                    Text("Практика")
                }
            }
        }
    }
}
