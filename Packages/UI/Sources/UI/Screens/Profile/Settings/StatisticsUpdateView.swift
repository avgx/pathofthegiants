import SwiftUI
import Env

struct StatisticsUpdateView: View {
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

