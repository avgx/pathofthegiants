import SwiftUI
import Env
import Models

struct ModuleCard: View {
    let module: ModuleData
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(module.name)
            Text(module.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
