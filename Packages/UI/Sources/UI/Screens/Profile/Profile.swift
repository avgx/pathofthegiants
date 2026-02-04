import SwiftUI

enum Profile: String, Codable, Identifiable, Sendable {
    case account
    case player
    case statistics
    case notifications
    case appleHealth
    case displaySettings
    case haptic
    case help
    
    var id: String {
        rawValue
    }
}

extension Profile {
    @MainActor
    @ViewBuilder
    var navigationLabel: some View {
        Label(navigationTitle, systemImage: systemImage)
    }
    
    var systemImage: String {
        switch self {
        case .account:
            "pencil"
        case .player:
            "play"
        case .statistics:
            "chart.line.uptrend.xyaxis"
        case .notifications:
            "bell.badge"
        case .appleHealth:
            "heart.text.clipboard" //"circle.hexagonpath" //"brain.head.profile"
//        case .gameCenter:
//            "laurel.leading.laurel.trailing"
        case .displaySettings:
            "wand.and.sparkles"
        case .haptic:
            "waveform.path"
        case .help:
            "questionmark.circle"
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .account:
            "Аккаунт"
        case .player:
            "Проигрыватель"
        case .statistics:
            "Статистика"
        case .notifications:
            "Уведомления"
        case .appleHealth:
            "Apple Health"
        case .displaySettings:
            "Оформление"
        case .haptic:
            "Виброотклик"
        case .help:
            "Путь великанов"
        }
    }
    
    @MainActor
    @ViewBuilder
    var navigationLink: some View {
        NavigationLink(value: self) {
            self.navigationLabel
        }
    }
    
    @MainActor
    @ViewBuilder
    var destination: some View {
        Group {
            switch self {
            case .account:
                AccountView()
            case .player:
                PlayerView()
            case .statistics:
                StatisticsView()
            case .notifications:
                NotificationsView()
            case .appleHealth:
                AppleHealthView()
            case .displaySettings:
                DisplaySettingsView()
            case .haptic:
                HapticSettingsView()
            case .help:
                AboutView()
            }
        }
        .navigationTitle(self.navigationTitle)
    }
}
