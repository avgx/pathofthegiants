import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    @Published var selectedTheme: ColorScheme? = nil {
        didSet {
            saveTheme()
        }
    }
    
    private let themeKey = "selectedTheme"
    
    public static let shared = ThemeManager()
    
    private init() {
        loadTheme()
    }
    
    private func saveTheme() {
        let themeIndex: Int
        switch selectedTheme {
        case .none: themeIndex = 0
        case .light: themeIndex = 1
        case .dark: themeIndex = 2
        @unknown default: themeIndex = 0
        }
        
        UserDefaults.standard.set(themeIndex, forKey: themeKey)
    }
    
    private func loadTheme() {
        let themeIndex = UserDefaults.standard.integer(forKey: themeKey)
        
        switch themeIndex {
        case 0: selectedTheme = nil
        case 1: selectedTheme = .light
        case 2: selectedTheme = .dark
        default: selectedTheme = nil
        }
    }
    
    enum Theme: String, CaseIterable {
        case system = "Системная"
        case light = "Светлая"
        case dark = "Темная"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
        
        var icon: String {
            switch self {
            case .system: return "gearshape"
            case .light: return "sun.max"
            case .dark: return "moon"
            }
        }
    }
}
