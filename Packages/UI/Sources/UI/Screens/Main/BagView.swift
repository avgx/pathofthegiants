import SwiftUI
import Env
import Models

struct BagView: View {
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
            //TODO: нужен для фон? как в модулях
            .navigationTitle("Сундук")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .navigationViewStyle(.stack)
    }
}
