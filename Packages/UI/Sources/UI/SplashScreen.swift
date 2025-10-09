import SwiftUI
import Env

struct SplashScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    @Binding var complete: Bool
    
    var body: some View {
        VStack {
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                try? await currentAccount.connect()
                withAnimation {
                    complete = true
                }
            }
        }
    }
}
