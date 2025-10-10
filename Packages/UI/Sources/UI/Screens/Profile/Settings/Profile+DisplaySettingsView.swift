import SwiftUI

extension Profile {
    struct DisplaySettingsView: View {
        @EnvironmentObject var themeManager: ThemeManager
        
        var body: some View {
            List {
                Section {
                    Picker("Тема", selection: Binding(
                        get: {
                            themeManager.selectedTheme == nil ? ThemeManager.Theme.system :
                            themeManager.selectedTheme == .light ? ThemeManager.Theme.light : ThemeManager.Theme.dark
                        },
                        set: { newValue in
                            themeManager.selectedTheme = newValue.colorScheme
                        }
                    )) {
                        ForEach(ThemeManager.Theme.allCases, id: \.self) { theme in
                            HStack {
                                //Image(systemName: theme.icon)
                                Text(theme.rawValue)
                            }
                            .tag(theme)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
}
