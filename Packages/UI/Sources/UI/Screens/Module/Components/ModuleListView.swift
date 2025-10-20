import SwiftUI
import Env
import Models

struct ModuleListView: View {
    let modules: [ModuleData]
    
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
            
            ForEach(modules.sorted(using: KeyPathComparator(\.id, order: .forward))) { module in
                Section {
                    ZStack {
                        NavigationLink(value: module) {
                            EmptyView()
                        }.opacity(0.0)
                        ModuleCard(module: module)
                    }
                    .aspectRatio(16.0/9.0, contentMode: .fill)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
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
        })
    }
}


