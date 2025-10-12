import SwiftUI
import Env

extension Profile {
    struct AppleHealthView: View {
        @EnvironmentObject var settingsManager: SettingsManager
        @EnvironmentObject private var healthKitManager: HealthKitManager
        
        @State var enabled = false
        
        var body: some View {
            List {
                Section {
                    Toggle("Сохранение", isOn: $settingsManager.appleHealthEnabled)
                } footer: {
                    Text("Сохранение количества прослушанных минут медитации в Apple Health для отслеживания этих данных в приложении Здоровье")
                }
            }
            .onAppear {
                if settingsManager.appleHealthEnabled {
                    Task {
                        let isAuthorized = await healthKitManager.authorizationStatusAuthorized()
                        if isAuthorized {
                            print("Доступ к HealthKit предоставлен")
                        } else {
                            print("Доступа к HealthKit нет")
                        }
                    }
                }
            }
            .onChange(of: enabled) { _, newValue in
                if newValue {
                    // Запрашиваем авторизацию
                    Task {
                        let isAuthorized = await healthKitManager.requestAuthorization()
                        
                        if isAuthorized {
                            print("Доступ к HealthKit предоставлен")
                        } else {
                            print("Доступ к HealthKit отклонен")
                        }
                    }
                }
            }
        }
    }
}
