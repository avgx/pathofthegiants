import SwiftUI
import Env

struct MainScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    var body: some View {
        TabView {
            Tab("Путь", systemImage: /*"figure.walk"*/"road.lanes") {
                DouView()
            }
            Tab("Сундук", systemImage: "bag") {
                BagView()
            }
            Tab("Профиль", systemImage: "person") {
                ProfileScreen()
            }
        }
    }
}

#Preview {
    MainScreen()
        .environmentObject(CurrentAccount.shared)
}
