import SwiftUI
import Env

struct TrialScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    var body: some View {
        NavigationStack {
            Group {
                if let trial = currentAccount.trial {
                    TrialListView(trialData: trial.data)
                } else {
                    ContentUnavailableView("ничего нет", systemImage: "magnifyingglass")
                }
            }
            .navigationTitle("Вне Пути")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {
                        currentAccount.disconnect()
                    }) {
                        Text("Выход")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    TrialScreen()
        .environmentObject(CurrentAccount.shared)
        .onAppear {
            Task {
                try? await CurrentAccount.shared.setTrial()
            }
        }
}
