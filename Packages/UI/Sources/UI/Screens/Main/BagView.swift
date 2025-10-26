import SwiftUI
import Env
import Models

struct BagView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let subtitle = "В сундуке хранятся все доступные практики"
    
    var body: some View {
        NavigationStack {
            Group {
                if let practices = currentAccount.practices {
                    PracticeGroupListView(practices: practices.data, subtitle: subtitle)
                } else {
                    ContentUnavailableView("Практики недоступны", systemImage: "exclamationmark.triangle")
                }
            }
            .scrollContentBackground(.hidden) // This hides the default form background
            .background(backgroundView)
            .navigationTitle("Сундук")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if settingsManager.moduleBackground {
            MainBackground()
                .aspectRatio(contentMode: .fill)
                .blur(radius: CGFloat(settingsManager.moduleBackgroundBlur))
                .ignoresSafeArea()
        } else {
            // Обязательно нужен else
            // Лучшие варианты для дефолтного фона:
            Color(.systemGroupedBackground) // 👈 Самый точный аналог дефолтного
                .ignoresSafeArea()
        }
    }
}
