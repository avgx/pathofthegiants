import SwiftUI
import Env

extension Profile {
    struct DisplaySettingsView: View {
        @EnvironmentObject var themeManager: ThemeManager
        @EnvironmentObject var settingsManager: SettingsManager
        
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
                
                Section {
                    Toggle("Изображение перед списком практик", isOn: $settingsManager.moduleImage)
                    Toggle("Фон", isOn: $settingsManager.moduleBackground)
                       
                    if settingsManager.moduleBackground {
                        HStack {
                            Text("Размытие фона")
                            Slider(
                                value: Binding(
                                    get: { settingsManager.moduleBackgroundBlur },
                                    set: { newValue in
                                        // Обновляем асинхронно
                                        DispatchQueue.main.async {
                                            settingsManager.moduleBackgroundBlur = newValue
                                        }
                                    }
                                ),
                                in: 0...100)
                            Text("\(Int(settingsManager.moduleBackgroundBlur))")
                        }
                    }
                    
                } header: {
                    Text("Модуль")
                }
            }
        }
    }
}
