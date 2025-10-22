import SwiftUI
import Env

extension Profile {
    struct NotificationsView: View {
        @Environment(\.scenePhase) var scenePhase
        @EnvironmentObject var settingsManager: SettingsManager
        @EnvironmentObject private var notificationManager: NotificationManager
        
        @State var isDenied = false
        @State var testNotificationPresented = false
        
        var body: some View {
            List {
                if isDenied {
                    Section {
                        Button(action: { openAppSettings() }) {
                            Text("Открыть Настройки")
                        }
                    } header: {
                        Text("Напоминания отключены")
                    } footer: {
                        Text("Чтобы использовать эту функцию, разрешите приложению присылать уведомления в Настройках")
                    }
                } else {
                    Section {
                        Toggle("Включить", isOn: $settingsManager.notificationTimeEnabled)
                        
                        if settingsManager.notificationTimeEnabled && !isDenied {
                            DatePicker(
                                "Время",
                                selection: $settingsManager.notificationTime,
                                displayedComponents: .hourAndMinute
                            )
                            .onChange(of: settingsManager.notificationTime) {
                                Task { @MainActor in
                                    print(settingsManager.notificationTime.formatted(date: .omitted, time: .shortened))
                                    notificationManager.meditationTime = settingsManager.notificationTime
                                    await notificationManager.scheduleMeditationNotification()
                                }
                            }
                        }
                        
                    } header: {
                        HStack {
                            Text("Напоминания")
                            Spacer()
                            Button(action: {
                                    Task {
                                        await notificationManager.sendTestNotification()
                                    }
                            }) {
                                let image = testNotificationPresented ? "checkmark.circle" : "checkmark.circle.badge.questionmark"
                                Label("Тест", systemImage: image)
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(testNotificationPresented ? .green : .secondary)
                            }
                        }
                    } footer: {
                        if settingsManager.notificationTimeEnabled {
                            Text("Вы будете получать ежедневные напоминания в \(notificationManager.meditationTime.formatted(date: .omitted, time: .shortened))")
                        }
                         
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .testNotificationPresented)) { notification in
                //handleTestNotificationPresented()
                testNotificationPresented = true
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
                notificationManager.meditationTime = settingsManager.notificationTime
                checkAuthorizationStatus()
            }
            .onChange(of: settingsManager.notificationTimeEnabled) { _, newValue in
                if newValue {
                    // Запрашиваем авторизацию
                    Task {
                        let isAuthorized = await notificationManager.requestAuthorization()
                        
                        if isAuthorized {
                            print("Уведомления разрешены")
                        } else {
                            print("Уведомления запрещены")
                        }
                    }
                } else {
                    testNotificationPresented = false
                }
            }
        }
        
        func checkAuthorizationStatus() {
            Task { @MainActor in
                testNotificationPresented = false
                isDenied = await notificationManager.authorizationStatusDenied()
                if isDenied {
                    print("Уведомления запрещены")
                } else {
                    print("Уведомления разрешены или неопределено")
                }
            }
        }
        
        func openAppSettings() {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            DispatchQueue.main.async {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
    }
}
