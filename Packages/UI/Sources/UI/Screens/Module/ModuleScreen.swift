import SwiftUI
import Env
import Models

struct ModuleScreen: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let module: ModuleData
    
    var body: some View {
        PracticeListView(practices: module.practices, subtitle: nil, image: module.image)
            .navigationTitle(module.name)
            .navigationSubtitle(module.description)
            .toolbarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .scrollContentBackground(.hidden) // This hides the default form background
            .background(backgroundView)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if settingsManager.moduleBackground {
            ModuleImage(moduleImage: module.image)
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        } else {
            // Обязательно нужен else
            //Color.clear
            Rectangle().fill(.ultraThinMaterial)
                .ignoresSafeArea()
        }
    }
}
