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
        zoomNavigationTransition = storage.zoomNavigationTransition
        hapticButtonPressEnabled = storage.hapticButtonPressEnabled
        hapticDataRefreshEnabled = storage.hapticDataRefreshEnabled
        hapticNotificationEnabled = storage.hapticNotificationEnabled
        hapticTabSelectionEnabled = storage.hapticTabSelectionEnabled
        uiStyle = storage.uiStyle
    }
    
    private func applyUiStyle() {
        switch uiStyle {
        case .classic:
            listRowMaterialBackground = true
            moduleBackground = true
            moduleBackgroundBlur = 12
            moduleImage = false
            zoomNavigationTransition = false
        case .brutalNordic:
            listRowMaterialBackground = false
            moduleBackground = false
            moduleImage = false
            zoomNavigationTransition = false
        case .zoomer:
            listRowMaterialBackground = true
            moduleBackground = true
            moduleBackgroundBlur = 12
            moduleImage = true
            zoomNavigationTransition = true
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
        @AppStorage("settings.zoomNavigationTransition")  var zoomNavigationTransition: Bool = false
        @AppStorage("settings.hapticButtonPressEnabled")  var hapticButtonPressEnabled = true
        @AppStorage("settings.hapticDataRefreshEnabled")  var hapticDataRefreshEnabled = true
        @AppStorage("settings.hapticNotificationEnabled") var hapticNotificationEnabled = true
        @AppStorage("settings.hapticTabSelectionEnabled") var hapticTabSelectionEnabled = true
        
        @AppStorage("settings.uiStyle") var uiStyle: Style = .classic
        
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
