import SwiftUI
import Env

public struct ContentView: View {
    @StateObject var currentAccount = CurrentAccount.shared
    public init() {}
    
    public var body: some View {
        Group {
            if currentAccount.isTrial {
                TrialScreen()
            } else if currentAccount.account != nil {
                MainScreen()
            } else {
                LoginScreen()
            }
        }
        .environmentObject(currentAccount)
    }
}

#Preview {
    ContentView()
}
