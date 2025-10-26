import SwiftUI
import Env
import Models

@MainActor
struct ModuleCard: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
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
            .overlay(alignment: .trailing, content: {
                if module.practices.count > 0 {
                    let progress = moduleProgress()
                    ZStack(alignment: .center) {
                        ProgressCircleBadge(progress: .constant(progress))
                            .font(.largeTitle)
                            .fontWeight(.ultraLight)
                            .foregroundStyle(Color.accentColor)
                        Text("\(module.practices.count)")
                            .font(.footnote)
                    }
                    .padding(.horizontal)
                }
            })
        }
        .frame(maxWidth: .infinity)
        .background(ModuleImage(moduleImage: module.image))
    }
    
    /// Учитываем только полностью завершенные практики
    private func moduleProgress() -> Double {
        guard module.practices.count > 0 else { return 0.0 }
        let progress = currentAccount.tracker.progress
        let complete: Int = module.practices.reduce(into: 0) { res, practice in
            res += Int(progress[practice.id] ?? 0) == practice.audioDuration ? 1 : 0
        }
        return Double(complete) / Double(module.practices.count)
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
