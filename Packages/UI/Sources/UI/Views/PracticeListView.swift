import SwiftUI
import Env
import Models

struct PracticeListView: View {
    let practices: [Practice]
    
    var body: some View {
        let groups = Array(Set(practices.map { $0.group })).sorted()
        List {
            ForEach(groups, id: \.self) { group in
                Section {
                    let groupPractices = practices.filter({ $0.group == group })
                    ForEach(groupPractices) { practice in
                        PracticeCard(practice: practice)
                    }
                } header: {
                    Text(group)
                }
            }
        }
    }
}
