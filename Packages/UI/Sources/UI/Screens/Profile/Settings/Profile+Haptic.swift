import SwiftUI
import Env

extension Profile {
    struct HapticSettingsView: View {
        @EnvironmentObject var settingsManager: SettingsManager
        
        var body: some View {
            List {
                Section {
                    Toggle("Нажатие на кнопку", isOn: $settingsManager.hapticButtonPressEnabled)
                    Toggle("Обновление данных", isOn: $settingsManager.hapticDataRefreshEnabled)
                    Toggle("Уведомление", isOn: $settingsManager.hapticNotificationEnabled)
                    Toggle("Выбор таба", isOn: $settingsManager.hapticTabSelectionEnabled)
                }
            }
        }
    }
}
