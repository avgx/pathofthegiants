import SwiftUI
import Env
import Models

struct ModuleScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let module: ModuleData
    
    var body: some View {
        PracticeListView(practices: module.practices, subtitle: module.description)
            .navigationTitle(module.name)
            .toolbarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .scrollContentBackground(.hidden) // This hides the default form background
            .background(
                ModuleImage(module: module)
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            )
    }
}
