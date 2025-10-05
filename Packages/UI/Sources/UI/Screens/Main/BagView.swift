import SwiftUI
import Env
import Models

struct BagView: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    var body: some View {
        NavigationStack {
            Group {
                if let practices = currentAccount.practices {
                    PracticeListView(practices: practices.data)
                } else {
                    ContentUnavailableView("no practices", systemImage: "exclamationmark.triangle")
                }
            }
            .navigationTitle("Сундук")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .navigationViewStyle(.stack)
    }
}
