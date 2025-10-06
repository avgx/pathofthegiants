import SwiftUI
import Env
import Models

struct DouView: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    var body: some View {
        NavigationStack {
            Group {
                if let modules = currentAccount.regular {
                    ModuleListView(modules: modules.data)
                } else {
                    ContentUnavailableView("Пути скрыты", systemImage: "exclamationmark.triangle")
                }
            }
            .navigationTitle("Пути")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .navigationViewStyle(.stack)
    }
}
