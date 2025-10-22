import UIKit
import UserNotifications
import Env

public class AppDelegate: NSObject, UIApplicationDelegate {
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Устанавливаем делегат для обработки уведомлений
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    nonisolated public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                           willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        if notification.request.identifier == "testNotification" {
            await handleTestNotification()
        }
        return [.banner, .sound]
    }
    
    nonisolated public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                           didReceive response: UNNotificationResponse) async {
        if response.notification.request.identifier == "meditationReminder" {
            // Обработка нажатия на уведомление о медитации
            print("Переход к медитации из уведомления")
            await handleMeditationNotification()
        } else if response.notification.request.identifier == "testNotification" {
            print("Открыто тестовое уведомление")
        }
    }
    
    @MainActor
    private func handleTestNotification() async {
        // Можно отправить уведомление через NotificationCenter
        NotificationCenter.default.post(name: .testNotificationPresented, object: nil)
    }
    
    @MainActor
    private func handleMeditationNotification() async {
        // Можно отправить уведомление через NotificationCenter
        NotificationCenter.default.post(name: .meditationNotificationTapped, object: nil)
    }
}

extension Notification.Name {
    static let meditationNotificationTapped = Notification.Name("meditationNotificationTapped")
    static let testNotificationPresented = Notification.Name("testNotificationPresented")
}
