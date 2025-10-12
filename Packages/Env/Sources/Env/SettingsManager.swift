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
    
    @Published public var appleHealthEnabled = true {
        didSet {
            storage.appleHealthEnabled = appleHealthEnabled
        }
    }
    
    private var storage = Storage()
    
    public static let shared = SettingsManager()
    
    private init() {
        statisticsUpdate = storage.statisticsUpdate
        playerSeekEnabled = storage.playerSeekEnabled
        appleHealthEnabled = storage.appleHealthEnabled
    }
}

extension SettingsManager {
    struct Storage {
        @AppStorage("settings.statisticsUpdate") var statisticsUpdate: StatisticsUpdate = .seconds
        @AppStorage("settings.playerSeekEnabled") var playerSeekEnabled: Bool = true
        @AppStorage("settings.appleHealthEnabled") var appleHealthEnabled: Bool = false
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
