import SwiftUI
import Env
import Models

struct ModuleScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isPresented
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
            .scrollBounceBehavior(.basedOnSize)
            .background(backgroundView)
            .if(settingsManager.zoomNavigationTransition) { view in
                view
                    .navigationBarBackButtonHidden()
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action:{ dismiss() }){
                                Image(systemName: "xmark")
                            }
                            .buttonBorderShape(.circle)
                            .opacity(0.2)
                        }
                    }
            }
            .lifecycleLog(String(reflecting: Self.self))
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if settingsManager.moduleBackground {
            ModuleImage(moduleImage: module.image)
                .aspectRatio(contentMode: .fill)
                .blur(radius: CGFloat(settingsManager.moduleBackgroundBlur))
                .ignoresSafeArea()
        } else {
            // Обязательно нужен else
            //Color.clear
            Rectangle().fill(.ultraThinMaterial)
                .ignoresSafeArea()
        }
    }
}
