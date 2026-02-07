import SwiftUI

@MainActor
public class SettingsManager: ObservableObject {
    @Published public var statisticsUpdate: StatisticsUpdate = .seconds {
        didSet {
            storage.statisticsUpdate = statisticsUpdate
        }
    }
    
    @Published public var playerSeekEnabled = true {
        didSet {
            storage.playerSeekEnabled = playerSeekEnabled
            AudioPlayer.shared.setSeekEnabled(playerSeekEnabled)
        }
    }
    @Published public var playerContinueProgress = true {
        didSet {
            storage.playerContinueProgress = playerContinueProgress
        }
    }
    
    @Published public var appleHealthEnabled = true {
        didSet {
            storage.appleHealthEnabled = appleHealthEnabled
        }
    }
    
    @Published public var notificationTimeEnabled = true {
        didSet {
            storage.notificationTimeEnabled = notificationTimeEnabled
        }
    }
    
    @Published public var notificationTime: Date {
        didSet {
            storage.notificationTime = notificationTime
        }
    }
    
    @Published public var listRowMaterialBackground = true {
        didSet {
            storage.listRowMaterialBackground = listRowMaterialBackground
        }
    }
    
    @Published public var moduleBackground = true {
        didSet {
            storage.moduleBackground = moduleBackground
        }
    }
    
    @Published public var moduleBackgroundBlur: Double = 12 {
        didSet {
            storage.moduleBackgroundBlur = moduleBackgroundBlur
        }
    }
    
    @Published public var moduleImage = true {
        didSet {
            storage.moduleImage = moduleImage
        }
    }
    
    @Published public var practiceBackgroundBlur = 54.0 {
        didSet {
            storage.practiceBackgroundBlur = practiceBackgroundBlur
        }
    }
    
    @Published public var practiceBackgroundImageOpacity = 1.0 {
        didSet {
            storage.practiceBackgroundImageOpacity = practiceBackgroundImageOpacity
        }
    }
    
    @Published public var practiceBackgroundWhiteOpacity = 0.0 {
        didSet {
            storage.practiceBackgroundWhiteOpacity = practiceBackgroundWhiteOpacity
        }
    }
    
    @Published public var practiceBackgroundBlackOpacity = 0.24 {
        didSet {
            storage.practiceBackgroundBlackOpacity = practiceBackgroundBlackOpacity
        }
    }
    
    @Published public var practiceGlassEffectOnCard = false {
        didSet {
            storage.practiceGlassEffectOnCard = practiceGlassEffectOnCard
        }
    }
    
    @Published public var practiceGlassEffectOnControls = false {
        didSet {
            storage.practiceGlassEffectOnControls = practiceGlassEffectOnControls
        }
    }
    
    @Published public var zoomNavigationTransition = false {
        didSet {
            storage.zoomNavigationTransition = zoomNavigationTransition
        }
    }
    
    @Published public var hapticButtonPressEnabled = true {
        didSet {
            storage.hapticButtonPressEnabled = hapticButtonPressEnabled
        }
    }
    @Published public var hapticDataRefreshEnabled = true {
        didSet {
            storage.hapticDataRefreshEnabled = hapticDataRefreshEnabled
        }
    }
    @Published public var hapticNotificationEnabled = true {
        didSet {
            storage.hapticNotificationEnabled = hapticNotificationEnabled
        }
    }
    @Published public var hapticTabSelectionEnabled = true {
        didSet {
            storage.hapticTabSelectionEnabled = hapticTabSelectionEnabled
        }
    }
    
    @Published public var uiStyle: Style = .classic {
        didSet {
            storage.uiStyle = uiStyle
            applyUiStyle()
        }
    }
    
    @Published public var accentLight: Color = Color(hex: "#D78D15") ?? .accentColor {
        didSet {
            storage.accentLight = accentLight
        }
    }

    @Published public var accentDark: Color = Color(hex: "#F6A700") ?? .accentColor {
        didSet {
            storage.accentDark = accentDark
        }
    }
    
    @Published public var customAccentColor: Bool = false {
        didSet {
            storage.customAccentColor = customAccentColor
        }
    }
    
    private var storage = Storage()
    
    public static let shared = SettingsManager()
    
    private init() {
        statisticsUpdate = storage.statisticsUpdate
        playerSeekEnabled = storage.playerSeekEnabled
        playerContinueProgress = storage.playerContinueProgress
        appleHealthEnabled = storage.appleHealthEnabled
        notificationTimeEnabled = storage.notificationTimeEnabled
        notificationTime = storage.notificationTime
        listRowMaterialBackground = storage.listRowMaterialBackground
        moduleBackground = storage.moduleBackground
        moduleBackgroundBlur = storage.moduleBackgroundBlur
        moduleImage = storage.moduleImage
        practiceBackgroundBlur = storage.practiceBackgroundBlur
        practiceBackgroundImageOpacity = storage.practiceBackgroundImageOpacity
        practiceBackgroundWhiteOpacity = storage.practiceBackgroundWhiteOpacity
        practiceBackgroundBlackOpacity = storage.practiceBackgroundBlackOpacity
        practiceGlassEffectOnCard = storage.practiceGlassEffectOnCard
        practiceGlassEffectOnControls = storage.practiceGlassEffectOnControls
        zoomNavigationTransition = storage.zoomNavigationTransition
        hapticButtonPressEnabled = storage.hapticButtonPressEnabled
        hapticDataRefreshEnabled = storage.hapticDataRefreshEnabled
        hapticNotificationEnabled = storage.hapticNotificationEnabled
        hapticTabSelectionEnabled = storage.hapticTabSelectionEnabled
        uiStyle = storage.uiStyle
        accentLight = storage.accentLight
        accentDark = storage.accentDark
        customAccentColor = storage.customAccentColor
    }
    
    private func applyUiStyle() {
        switch uiStyle {
        case .classic:
            listRowMaterialBackground = true
            moduleBackground = true
            moduleBackgroundBlur = 12
            moduleImage = false
            practiceBackgroundBlur = 54
            practiceBackgroundImageOpacity = 1.0
            practiceBackgroundWhiteOpacity = 0.0
            practiceBackgroundBlackOpacity = 0.24
            practiceGlassEffectOnCard = false
            practiceGlassEffectOnControls = false
            zoomNavigationTransition = false
            customAccentColor = false
        case .brutalNordic:
            listRowMaterialBackground = false
            moduleBackground = false
            moduleImage = false
            practiceBackgroundBlur = 54
            practiceBackgroundImageOpacity = 1.0
            practiceBackgroundWhiteOpacity = 0.0
            practiceBackgroundBlackOpacity = 0.24
            practiceGlassEffectOnCard = false
            practiceGlassEffectOnControls = false
            zoomNavigationTransition = false
            customAccentColor = false
        case .zoomer:
            listRowMaterialBackground = true
            moduleBackground = true
            moduleBackgroundBlur = 12
            moduleImage = true
            practiceBackgroundBlur = 54
            practiceBackgroundImageOpacity = 1.0
            practiceBackgroundWhiteOpacity = 0.0
            practiceBackgroundBlackOpacity = 0.24
            practiceGlassEffectOnCard = true
            practiceGlassEffectOnControls = true
            zoomNavigationTransition = true
            customAccentColor = false
        case .custom:
            break
        }
    }
}

extension SettingsManager {
    struct Storage {
        @AppStorage("settings.statisticsUpdate")        var statisticsUpdate: StatisticsUpdate = .seconds
        @AppStorage("settings.playerSeekEnabled")       var playerSeekEnabled: Bool = true
        @AppStorage("settings.playerContinueProgress")  var playerContinueProgress: Bool = true
        @AppStorage("settings.appleHealthEnabled")      var appleHealthEnabled: Bool = false
        @AppStorage("settings.notificationTimeEnabled") var notificationTimeEnabled: Bool = false
        @AppStorage("settings.notificationTime")        var notificationTime: Date = defaultTime
        @AppStorage("settings.listRowMaterialBackground") var listRowMaterialBackground: Bool = true
        @AppStorage("settings.moduleBackground")        var moduleBackground: Bool = true
        @AppStorage("settings.moduleBackgroundBlur")    var moduleBackgroundBlur: Double = 12
        @AppStorage("settings.moduleImage")             var moduleImage: Bool = true
        @AppStorage("settings.practiceBackgroundBlur")  var practiceBackgroundBlur = 54.0
        @AppStorage("settings.practiceBackgroundImageOpacity") var practiceBackgroundImageOpacity = 1.0
        @AppStorage("settings.practiceBackgroundWhiteOpacity") var practiceBackgroundWhiteOpacity = 0.0
        @AppStorage("settings.practiceBackgroundBlackOpacity") var practiceBackgroundBlackOpacity = 0.24
        @AppStorage("settings.practiceGlassEffectOnCard") var practiceGlassEffectOnCard = false
        @AppStorage("settings.practiceGlassEffectOnControls") var practiceGlassEffectOnControls = false
        @AppStorage("settings.zoomNavigationTransition")  var zoomNavigationTransition: Bool = false
        @AppStorage("settings.hapticButtonPressEnabled")  var hapticButtonPressEnabled = true
        @AppStorage("settings.hapticDataRefreshEnabled")  var hapticDataRefreshEnabled = true
        @AppStorage("settings.hapticNotificationEnabled") var hapticNotificationEnabled = true
        @AppStorage("settings.hapticTabSelectionEnabled") var hapticTabSelectionEnabled = true
        
        @AppStorage("settings.uiStyle") var uiStyle: Style = .classic
        @AppStorage("settings.accentLight") var accentLight: Color = Color(hex: "#D78D15") ?? .accentColor
        @AppStorage("settings.accentDark") var accentDark: Color = Color(hex: "#F6A700") ?? .accentColor
        @AppStorage("settings.customAccentColor") var customAccentColor: Bool = false
        
        static let defaultTime: Date = {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.hour, .minute], from: Date())
            components.hour = 22
            components.minute = 0
            return calendar.date(from: components) ?? Date()
        }()
    }
}

extension SettingsManager {
    public enum StatisticsUpdate: String, Codable, CaseIterable, Identifiable, Sendable, CustomStringConvertible {
        case seconds
        case complete
        
        public var id: String {
            rawValue
        }
        
        public var description: String {
            switch self {
            case .seconds:
                "каждую секунду"
            case .complete:
                "только проведенную от начала и до конца"
            }
        }
    }
}

extension SettingsManager {
    public enum Style: String, Codable, CaseIterable, Identifiable, Sendable, CustomStringConvertible {
        case classic
        case brutalNordic
        case zoomer
        case custom
        
        public var id: String {
            rawValue
        }
        
        public var description: String {
            switch self {
            case .classic:
                "Классический"
            case .brutalNordic:
                "Суровый"
            case .zoomer:
                "Зумерский"
            case .custom:
                "Настраиваемый"
            }
        }
    }
}
