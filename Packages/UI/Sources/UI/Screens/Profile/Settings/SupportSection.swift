import SwiftUI
import Env
import DeviceKit
import LivsyToast
import StoreKit

struct SupportSection: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    @EnvironmentObject var settingsManager: SettingsManager
    @State var showLogs = false
    @State private var showingShareSheet = false
    
    var body: some View {
        Section {
            /// Ask a Question
            Link(
                destination: URL.mailto(
                    "pathofthegiants@gmail.com",
                    subject: "Путь великанов",
                    body: """
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        ID: \(currentAccount.accountInfo?.data.userID ?? "-")
                        Подписка до: \(currentAccount.accountInfo?.data.subscriptionEndDate ?? "-")
                        TZ: \(TimeZone.current)
                        Версия: \(Bundle.main.versionBuild)
                        Устройство: \(Device.current)
                        Диагональ: \(Device.current.diagonal)
                        Яркость: \(Device.current.screenBrightness)
                        Экран: \(Int(UIScreen.main.bounds.width))x\(Int(UIScreen.main.bounds.height))
                        iOS: \(UIDevice.current.systemVersion)
                        """
                )!,
                label: {
                Label("Задать вопрос", systemImage: "mail")
            })
            .buttonStyle(.plain)
            
            Link(destination: URL(string: "https://github.com/avgx/pathofthegiants/issues")!, label: {
                Label("Сообщить об ошибке", systemImage: "ladybug")
            })
            .buttonStyle(.plain)
#if DEBUG
            Button(action: { showLogs.toggle() }) {
                Label("Отладка", systemImage: "list.bullet.clipboard")
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showLogs) {
                LogsSheetView()
            }
#endif
            Button(action: { SKStoreReviewController.requestReview() }) {
                /// Rate app
                Label("Оценить приложение", systemImage: "star")
            }
            .buttonStyle(.plain)
            Button(action: { showingShareSheet.toggle() }) {
                /// Share the app
                Label("Поделиться", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [Bundle.main.appStoreURL])
            }
        } header: {
            ///Support
            Text("Поддержка")
        }        
    }
}
