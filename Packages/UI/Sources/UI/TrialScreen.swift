import SwiftUI
import Env

public struct TrialScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    public init() {}
    
    public var body: some View {
        VStack {
            Text("Trial")
            if let trial = currentAccount.trial {
                Text("\(trial)")
            }
            
            Button(action: {
                currentAccount.disconnect()
            }) {
                Text("logout")
            }
        }
        .padding()
    }
}

#Preview {
    TrialScreen()
        .environmentObject(CurrentAccount.shared)
}
