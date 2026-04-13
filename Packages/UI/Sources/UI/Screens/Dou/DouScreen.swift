import SwiftUI
import Env
import Models

struct DouScreen: View, Loggable {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var currentAccount: CurrentAccount
    
    var body: some View {
        NavigationStack {
            Group {
                if let modules = currentAccount.regularModules {
                    ModuleListView(modules: modules)
                } else {
                    ContentUnavailableView("Путь скрыт", systemImage: "exclamationmark.triangle")
                }
            }
            .navigationTitle("Путь великанов")
            .scrollContentBackground(.hidden) // This hides the default form background
            .background(backgroundView)
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .navigationViewStyle(.stack)
        .lifecycleLog(String(reflecting: Self.self))
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if settingsManager.moduleBackground {
            ZStack {
                Color(.systemGroupedBackground)
                    .opacity(0.24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                MainBackground()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.7)
                    .blur(radius: CGFloat(settingsManager.moduleBackgroundBlur))
                    .ignoresSafeArea()
            }
            
        } else {
            // Обязательно нужен else
            // Лучшие варианты для дефолтного фона:
            Color(.systemGroupedBackground) // 👈 Самый точный аналог дефолтного
                .ignoresSafeArea()
        }
    }
}
