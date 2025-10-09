import SwiftUI
import Env

public struct ContentView: View {
    @StateObject var currentAccount = CurrentAccount.shared
    @State var initialLoadComplete: Bool = false
    
    public init() {}
    
    public var body: some View {
        Group {
            if !initialLoadComplete {
                SplashScreen(complete: $initialLoadComplete)
            } else if currentAccount.isTrial {
                TrialScreen()
            } else if currentAccount.token != nil {
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
