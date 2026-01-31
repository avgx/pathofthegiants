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
            if let image, settingsManager.moduleImage || settingsManager.zoomNavigationTransition {
                Section {
                    Color.clear
                        .background {
                            ModuleImage(moduleImage: image)
                        }
                        .if(settingsManager.zoomNavigationTransition) { view in
                            view.edgesIgnoringSafeArea(.top)
                        }
                }
                .listSectionSpacing(.compact)
                .listSectionSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .if(settingsManager.zoomNavigationTransition) { view in
                    view
                        .listSectionMargins(.horizontal, 0)
                        .listSectionMargins(.top, 0)
                        .aspectRatio(4.0/3.0, contentMode: .fit)
                }
                .if(!settingsManager.zoomNavigationTransition) { view in
                    view
                        .aspectRatio(16.0/9.0, contentMode: .fill)
                }
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
            //.listSectionMargins(.top, -40)
            //.zIndex(1)
        }
        .if(settingsManager.zoomNavigationTransition) { view in
            view
                .listStyle(.plain)  // Ключевой модификатор: убирает встроенные отступы List
                .edgesIgnoringSafeArea(.top)
        }
        .if(!settingsManager.zoomNavigationTransition) { view in
            view
                .listSectionSpacing(.compact)
                .padding(.top, -32) // Отрицательный паддинг чтобы придвинуть к навигации
            //.padding(.top, -(UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0))
        }
    }
}

