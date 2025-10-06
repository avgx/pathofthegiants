import SwiftUI
import Env
import Models

struct ModuleListView: View {
    let modules: [ModuleData]
    
    var body: some View {
        List {
            ForEach(modules.sorted(using: KeyPathComparator(\.id, order: .forward))) { module in
                Section {
                    ModuleCard(module: module)
                }
            }
        }
    }
}


