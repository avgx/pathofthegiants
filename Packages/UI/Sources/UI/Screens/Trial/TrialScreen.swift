import SwiftUI
import Env

struct TrialScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    @EnvironmentObject var tracker: SessionTracker
    
    var body: some View {
        NavigationStack {
            Group {
                if let trial = currentAccount.trialModules {
                    TrialListView(trialData: trial)
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
                        Text("Закрыть")
                    }
                }
            }
            .fullScreenCover(item: tracker.currentPracticeBinding) { practice in
                NavigationStack {
                    PracticeScreen(practice: practice)
                }
                .navigationViewStyle(.stack)
            }
        }
        .navigationViewStyle(.stack)
        .lifecycleLog(String(reflecting: Self.self))
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
