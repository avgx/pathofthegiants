import SwiftUI
import Env
import Models

struct ModuleListView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let modules: [ModuleData]
    
    @Namespace private var namespace
    
    var body: some View {
        List {
            Section {
                Text("Каждый путь включает практики разных типов, фоновую музыку и историю великана")
                    .font(.footnote)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .padding(.vertical, 2)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .listRowBackground(Color.clear)
            
            //.sorted(using: KeyPathComparator(\.id, order: .forward))
            ForEach(modules.sorted()) { module in
                Section {
                    ZStack {
                        NavigationLink(value: module) {
                            EmptyView()
                        }.onTapHaptic(.buttonPress).opacity(0.0)
                        ModuleCard(module: module)
                    }
                    .aspectRatio(16.0/9.0, contentMode: .fill)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .if(settingsManager.zoomNavigationTransition) { view in
                        //иногда Transition сбоит. нужно исследовать
                        view.matchedTransitionSource(id: module.id, in: namespace)
                    }
                    
                }
                .listSectionSpacing(.compact)
            }
        }
        .listSectionSpacing(.compact)
        .environment(\.defaultMinListHeaderHeight, 0) // Убираем отступы заголовков секций
        .environment(\.defaultMinListRowHeight, 0) // Убираем минимальную высоту рядов
        .padding(.top, -32) // Отрицательный паддинг чтобы придвинуть к навигации
        .navigationDestination(for: ModuleData.self, destination: { module in
            ModuleScreen(module: module)
                .if(settingsManager.zoomNavigationTransition) { view in
                    //иногда Transition сбоит. нужно исследовать
                    view.navigationTransition(.zoom(sourceID: module.id, in: namespace))
                }
        })
        .refreshable(action: {
            refresh()
        })
    }
    
    func refresh() {
        Task {
            URLCache.imageCache.removeAllCachedResponses()
            try? await currentAccount.connect()
        }
    }
}


