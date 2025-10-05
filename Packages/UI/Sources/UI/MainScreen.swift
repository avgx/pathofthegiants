import SwiftUI
import Env

public struct MainScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    public init() {}
    
    public var body: some View {
        TabView {
            Tab("Путь", systemImage: "map") {
                Text("Путь...")
                if let practices = currentAccount.practices {
                    Text("\(practices)")
                }
            }
            Tab("Сундук", systemImage: "bag") {
                Text("Сундук...")
            }
            Tab("Профиль", systemImage: "person") {
                VStack {
                    Button(action: { currentAccount.disconnect() }) {
                        Text("logout")
                    }
                }
            }
        }
    }
}

#Preview {
    MainScreen()
        .environmentObject(CurrentAccount.shared)
}
