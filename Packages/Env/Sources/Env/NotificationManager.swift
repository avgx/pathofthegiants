import UserNotifications
import SwiftUI

@MainActor
public class NotificationManager: ObservableObject {
    public static let shared = NotificationManager()
    
    @Published public var meditationTime: Date = SettingsManager.Storage.defaultTime
//    {
//        let calendar = Calendar.current
//        var components = calendar.dateComponents([.hour, .minute], from: Date())
//        components.hour = 22
//        components.minute = 0
//        return calendar.date(from: components) ?? Date()
//    }()
    
    private init() { }
    
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            
            if granted {
                print("Уведомления разрешены")
                await scheduleMeditationNotification()
            } else {
                print("Уведомления не разрешены")
            }
            
            return true
        } catch {
            print("Ошибка запроса разрешений: \(error.localizedDescription)")
            return false
        }
    }
    
    public func scheduleMeditationNotification() async {
        await removePendingNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "Время для практики"
        content.body = "Найдите несколько минут для спокойствия и осознанности"
        content.sound = .default
        
        guard let trigger = createDailyTrigger(for: meditationTime) else { return }
        
        let request = UNNotificationRequest(
            identifier: "meditationReminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Уведомление запланировано на \(meditationTime.formatted(date: .omitted, time: .shortened))")
        } catch {
            print("Ошибка планирования: \(error.localizedDescription)")
        }
    }
    
    private func createDailyTrigger(for date: Date) -> UNNotificationTrigger? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    }
    
    func removePendingNotifications() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["meditationReminder"])
    }
    
    public func authorizationStatusDenied() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .denied
    }
    
    @MainActor
    public func sendTestNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "Напоминание"
        content.body = "Тестовое"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "testNotification",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Тестовое уведомление отправлено")
        } catch {
            print("Ошибка отправки тестового уведомления: \(error.localizedDescription)")
        }
    }
}
