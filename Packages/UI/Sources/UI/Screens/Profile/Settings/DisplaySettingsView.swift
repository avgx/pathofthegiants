import SwiftUI
import Env


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
                
                Picker("Стиль", selection: $settingsManager.uiStyle) {
                    ForEach(SettingsManager.Style.allCases, id: \.self) { style in
                        HStack {
                            Text(style.description)
                        }
                        .tag(style)
                    }
                }
                .pickerStyle(.menu)
            } footer: {
                Text("настройки интерфейса переключатся в зависимости от выбранного стиля")
            }
            
            Section {
                Toggle("Настраиваемый", isOn: $settingsManager.customAccentColor)
                ColorPicker("В светлой теме", selection: $settingsManager.accentLight, supportsOpacity: false)
                ColorPicker("В темной теме", selection: $settingsManager.accentDark, supportsOpacity: false)
            } header: {
                Text("Цвет акцента")
            }
            .opacity(settingsManager.uiStyle == .custom ? 1.0 : 0.5)
            .disabled(settingsManager.uiStyle != .custom)
            
            Section {
                Toggle("Фон", isOn: $settingsManager.moduleBackground)
                
                if settingsManager.moduleBackground {
                    HStack {
                        Text("Размытие")
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
                Text("Экран")
            } footer: {
                Text("При отображении модуля или сундука используется фоновое изображение")
            }
            .opacity(settingsManager.uiStyle == .custom ? 1.0 : 0.5)
            .disabled(settingsManager.uiStyle != .custom)
            
            Section {
                Toggle("Фон", isOn: $settingsManager.listRowMaterialBackground)
            } header: {
                Text("Строки в списках")
            } footer: {
                Text("Стиль отображения строк практики, сундука или настроек")
            }
            .opacity(settingsManager.uiStyle == .custom ? 1.0 : 0.5)
            .disabled(settingsManager.uiStyle != .custom)
            
            Section {
                Toggle("Изображение перед списком практик", isOn: $settingsManager.moduleImage)
                Toggle("Навигация через зум", isOn: $settingsManager.zoomNavigationTransition)
            } header: {
                Text("Модуль")
            }
            .opacity(settingsManager.uiStyle == .custom ? 1.0 : 0.5)
            .disabled(settingsManager.uiStyle != .custom)
            
            Section {
                HStack {
                    Text("Прозрачность темной подложки")
                    Slider(
                        value: Binding(
                            get: { settingsManager.practiceBackgroundBlackOpacity * 100 },
                            set: { newValue in
                                // Обновляем асинхронно
                                DispatchQueue.main.async {
                                    settingsManager.practiceBackgroundBlackOpacity = Double(newValue) / 100.0
                                }
                            }
                        ),
                        in: 0...100)
                    Text("\(Int(settingsManager.practiceBackgroundBlackOpacity * 100))")
                }
                HStack {
                    Text("Прозрачность светлой подложки")
                    Slider(
                        value: Binding(
                            get: { settingsManager.practiceBackgroundWhiteOpacity * 100 },
                            set: { newValue in
                                // Обновляем асинхронно
                                DispatchQueue.main.async {
                                    settingsManager.practiceBackgroundWhiteOpacity = Double(newValue) / 100.0
                                }
                            }
                        ),
                        in: 0...100)
                    Text("\(Int(settingsManager.practiceBackgroundWhiteOpacity * 100))")
                }
                HStack {
                    Text("Размытие")
                    Slider(
                        value: Binding(
                            get: { settingsManager.practiceBackgroundBlur },
                            set: { newValue in
                                // Обновляем асинхронно
                                DispatchQueue.main.async {
                                    settingsManager.practiceBackgroundBlur = newValue
                                }
                            }
                        ),
                        in: 0...100)
                    Text("\(Int(settingsManager.practiceBackgroundBlur))")
                }
                HStack {
                    Text("Прозрачность")
                    Slider(
                        value: Binding(
                            get: { settingsManager.practiceBackgroundImageOpacity * 100 },
                            set: { newValue in
                                // Обновляем асинхронно
                                DispatchQueue.main.async {
                                    settingsManager.practiceBackgroundImageOpacity = Double(newValue) / 100.0
                                }
                            }
                        ),
                        in: 0...100)
                    Text("\(Int(settingsManager.practiceBackgroundImageOpacity * 100))")
                }
            } header: {
                Text("Фон практики")
            } footer: {
                Text("Диапазон прозрачности от 0 (совсем прозрачный) до 100 (совсем непрозрачный).")
            }
            .opacity(settingsManager.uiStyle == .custom ? 1.0 : 0.5)
            .disabled(settingsManager.uiStyle != .custom)
            
            Section {
                Toggle("Эффект стекла на карточке", isOn: $settingsManager.practiceGlassEffectOnCard)
                Toggle("Эффект стекла на управлении", isOn: $settingsManager.practiceGlassEffectOnControls)
            } header: {
                Text("Плеер")
            }
            .opacity(settingsManager.uiStyle == .custom ? 1.0 : 0.5)
            .disabled(settingsManager.uiStyle != .custom)
        }
    }
}

