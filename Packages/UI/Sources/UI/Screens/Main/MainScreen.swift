import SwiftUI
import Env

enum Feature: String, Identifiable, Hashable, CaseIterable, Codable, Sendable {
    case dou
    case bag
    case profile
    
    var id: String { rawValue }
}

struct MainScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    @EnvironmentObject var tracker: SessionTracker
    @State var selectedTab: Feature = .dou
    
//    private var selectedTabBinding: Binding<Feature> {
//        Binding(
//            get: { selectedTab },
//            set: { newValue in
//                HapticManager.shared.fireHaptic(.tabSelection)
//                selectedTab = newValue
//            }
//        )
//    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Путь", systemImage: "road.lanes", value: .dou) {
                DouScreen()
            }
            
            Tab("Сундук", systemImage: "bag", value: .bag) {
                BagScreen()
            }
            
            Tab("Профиль", systemImage: "person", value: .profile) {
                ProfileScreen()
            }
        }
        .onChange(of: selectedTab) {
            HapticManager.shared.fireHaptic(.tabSelection)
        }
        .fullScreenCover(item: tracker.currentPracticeBinding) { practice in
            NavigationStack {
                PracticeScreen(practice: practice)
            }
            .navigationViewStyle(.stack)
        }
    }
}

#Preview {
    MainScreen()
        .environmentObject(CurrentAccount.shared)
}
