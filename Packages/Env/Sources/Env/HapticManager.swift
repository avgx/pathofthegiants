import CoreHaptics
import SwiftUI
import UIKit

@MainActor
public class HapticManager {
    public static let shared: HapticManager = .init()

    public enum HapticType {
        case buttonPress
        case dataRefresh(intensity: CGFloat)
        case notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
        case tabSelection
    }
    
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private let settings = SettingsManager.shared
    
    private init() {
        selectionGenerator.prepare()
        impactGenerator.prepare()
    }
    
    @MainActor
    public func fireHaptic(_ type: HapticType) {
        guard supportsHaptics else { return }
        
        switch type {
        case .buttonPress:
            if settings.hapticButtonPressEnabled {
                impactGenerator.impactOccurred()
            }
        case let .dataRefresh(intensity):
            if settings.hapticDataRefreshEnabled {
                impactGenerator.impactOccurred(intensity: intensity)
            }
        case let .notification(type):
            if settings.hapticNotificationEnabled {
                notificationGenerator.notificationOccurred(type)
            }
        case .tabSelection:
            if settings.hapticTabSelectionEnabled {
                selectionGenerator.selectionChanged()
            }
        }
    }
    
    public var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
}

// MARK: - View Extensions
@MainActor
extension NavigationLink {
    public func onTapHaptic(_ type: HapticManager.HapticType) -> some View {
        self.simultaneousGesture(TapGesture().onEnded {
            HapticManager.shared.fireHaptic(type)
        })
    }
}
