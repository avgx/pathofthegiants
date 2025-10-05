import SwiftUI
import Env

struct MainScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    var body: some View {
        TabView {
            Tab("Путь", systemImage: "map") {
                DouView()
            }
            Tab("Сундук", systemImage: "bag") {
                BagView()
            }
            Tab("Профиль", systemImage: "person") {
                ProfileView()
            }
        }
    }
}

#Preview {
    MainScreen()
        .environmentObject(CurrentAccount.shared)
}
