import SwiftUI
import Env
import Models

@MainActor
struct ModuleCard: View {
    let module: ModuleData
    
    var body: some View {
        VStack(alignment: .leading) {
            labelOpen
                //.clipShape(.capsule)
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 20
                    )
                )
                .font(.footnote)
                .foregroundStyle(.white)
                .padding(.top, 16)
            Spacer()
            VStack(alignment: .leading) {
                Text(module.name)
                    .font(.subheadline)
                Text(module.description)
                    .font(.footnote)
                    .fontWeight(.light)
                    .foregroundStyle(.secondary)
            }
            .padding(8)
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
        }
        .frame(maxWidth: .infinity)
        .background(ModuleImage(module: module))
    }
    
    @ViewBuilder
    var labelOpen: some View {
        switch (module.opened, module.isPaid) {
        case (true, false):
            Text("Открыт")
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(.orange)
        case (true, true):
            Text("За монеты")
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(.purple)
        case (false, _):
            Text("Закрыт")
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(.gray)
        }
    }
}
