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
                    ContentUnavailableView("Trial", systemImage: "magnifyingglass")
                }
            }
            .navigationTitle("Trial")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {
                        currentAccount.disconnect()
                    }) {
                        Text("logout")
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
