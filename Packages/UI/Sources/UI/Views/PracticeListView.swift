import SwiftUI
import Env
import Models

struct PracticeListView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    let practices: [Practice]
    let subtitle: String?
    let image: String?
    
    var body: some View {
        List {
            if let image, settingsManager.moduleImage {
                Section {
                    ZStack {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .background(ModuleImage(moduleImage: image))
                    }
                    .aspectRatio(16.0/9.0, contentMode: .fill)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .listSectionSpacing(.compact)
            }
            
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
            
            Section {
                ForEach(practices) { practice in
                    PracticeCard(practice: practice)
                }
            }
            .listRowBackground(
                Rectangle().fill(.ultraThinMaterial)
            )
        }
        .listSectionSpacing(.compact)
        .environment(\.defaultMinListHeaderHeight, 0) // Убираем отступы заголовков секций
        .environment(\.defaultMinListRowHeight, 0) // Убираем минимальную высоту рядов
        .padding(.top, -32) // Отрицательный паддинг чтобы придвинуть к навигации
    }
}

