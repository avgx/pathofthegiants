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
    
    @Published public var moduleBackground = true {
        didSet {
            storage.moduleBackground = moduleBackground
        }
    }
    
    @Published public var moduleImage = true {
        didSet {
            storage.moduleImage = moduleImage
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
        moduleBackground = storage.moduleBackground
        moduleImage = storage.moduleImage
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
        @AppStorage("settings.moduleBackground")        var moduleBackground: Bool = true
        @AppStorage("settings.moduleImage")             var moduleImage: Bool = true
        
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
        case minutes
        case complete
        
        public var id: String {
            rawValue
        }
        
        public var description: String {
            switch self {
            case .seconds:
                "каждую секунду"
            case .minutes:
                "каждую минуту"
            case .complete:
                "только проведенную от начала и до конца"
            }
        }
    }
}
