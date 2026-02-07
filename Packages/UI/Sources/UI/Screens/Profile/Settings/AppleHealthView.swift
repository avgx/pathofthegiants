import SwiftUI
import Env


struct AppleHealthView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject private var healthKitManager: HealthKitManager
    
    @State var isSharingDenied = false
    
    
#if targetEnvironment(simulator)
    var body: some View {
        ContentUnavailableView("HealthKit недоступен в симуляторе", systemImage: "exclamationmark.triangle")
    }
    
#else
    var body: some View {
        List {
            if isSharingDenied {
                Section {
                    Button(action: { openAppSettings() }) {
                        Text("Открыть Настройки")
                    }
                } header: {
                    Text("Доступ к HealthKit запрещен")
                } footer: {
                    Text("Чтобы использовать эту функцию, разрешите приложению записывать данные о здоровье в Настройках → Конфиденциальность и безопасность → Здоровье")
                }
            } else {
                Section {
                    Toggle("Сохранение", isOn: $settingsManager.appleHealthEnabled)
                } footer: {
                    Text("Сохранение количества прослушанных минут медитации в Apple Health для отслеживания этих данных в приложении Здоровье")
                }
            }
        }
        .onChange(of: scenePhase) { _, newValue in
            switch newValue {
            case .active:
                checkAuthorizationStatus()
            default:
                break
            }
        }
        .onAppear {
            checkAuthorizationStatus()
        }
        .onChange(of: settingsManager.appleHealthEnabled) { _, newValue in
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
#endif
    func checkAuthorizationStatus() {
        if settingsManager.appleHealthEnabled {
            Task { @MainActor in
                isSharingDenied = await healthKitManager.authorizationStatusSharingDenied()
                if isSharingDenied {
                    print("Доступ к HealthKit запрещен")
                } else {
                    print("Доступ к HealthKit разрешен или неопределен")
                }
            }
        }
    }
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

