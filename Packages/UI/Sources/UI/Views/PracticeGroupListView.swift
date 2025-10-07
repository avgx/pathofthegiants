import SwiftUI
import Env
import Models

struct PracticeGroupListView: View {
    let practices: [Practice]
    let subtitle: String?
    
    var body: some View {
        let groups = Array(Set(practices.map { $0.group })).sorted()
        List {
            if let subtitle {
                Section {
                    Text(subtitle)
                        .font(.footnote)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .padding(.vertical, 2)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .listRowBackground(Color.clear)
            }
            
            ForEach(groups, id: \.self) { group in
                Section {
                    let groupPractices = practices.filter({ $0.group == group })
                    ForEach(groupPractices) { practice in
                        PracticeCard(practice: practice)
                    }
                } header: {
                    Text(group)
                }
                .listRowBackground(
                    Rectangle().fill(.ultraThinMaterial)
                )
            }
        }
        .listSectionSpacing(.compact)
        .environment(\.defaultMinListHeaderHeight, 0) // Убираем отступы заголовков секций
        .environment(\.defaultMinListRowHeight, 0) // Убираем минимальную высоту рядов
        .padding(.top, -32) // Отрицательный паддинг чтобы придвинуть к навигации
    }
}
