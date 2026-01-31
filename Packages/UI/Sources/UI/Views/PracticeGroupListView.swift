import SwiftUI
import Env
import Models

struct PracticeGroupListView: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let practices: [Practice]
    let subtitle: String?
    
    @State var groups: [String] = []
    
    var body: some View {
//        let groups = Array(Set(practices.map { $0.group }))
//            .sorted(using: KeyPathComparator(\.groupOrder, order: .forward))
        
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
                    let groupPractices = practices
                        .filter({ $0.group == group })
                        .sorted(using: KeyPathComparator(\.whenCreated, order: .forward))
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
        .padding(.top, -32) // Отрицательный паддинг чтобы придвинуть к навигации
        .onAppear {
            self.groups = Array(Set(practices.map { $0.group }))
                .sorted(using: KeyPathComparator(\.groupOrder, order: .forward))
        }
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
