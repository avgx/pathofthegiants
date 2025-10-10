import SwiftUI

enum Profile: String, Codable, Identifiable, Sendable {
    case account
    case notifications
    case appleHealth
    case gameCenter
    case displaySettings
    case help
    case info
    
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
        case .notifications:
            "bell.badge"
        case .appleHealth:
            "brain.head.profile"
        case .gameCenter:
            "laurel.leading.laurel.trailing"
        case .displaySettings:
            "wand.and.sparkles"
        case .help:
            "questionmark.circle"
        case .info:
            "info.circle"
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .account:
            "Аккаунт"
        case .notifications:
            "Уведомления"
        case .appleHealth:
            "Apple Health"
        case .gameCenter:
            "Game Center"
        case .displaySettings:
            "Оформление"
        case .help:
            "Помощь"
        case .info:
            "О приложении"
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
            case .notifications:
                NotificationsView()
            case .appleHealth:
                AppleHealthView()
            case .gameCenter:
                GameCenterView()
            case .displaySettings:
                DisplaySettingsView()
            case .help:
                HelpView()
            case .info:
                InfoView()
            }
        }
        .navigationTitle(self.navigationTitle)
    }
}
