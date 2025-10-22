import SwiftUI
import Env

public struct ContentView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var currentAccount = CurrentAccount.shared
    @StateObject private var audioPlayer = AudioPlayer.shared
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State var initialLoadComplete: Bool = false
    
    public init() {}
    
    public var body: some View {
        Group {
            if !initialLoadComplete {
                SplashScreen(complete: $initialLoadComplete)
            } else if currentAccount.isTrial {
                TrialScreen()
            } else if currentAccount.token != nil {
                MainScreen()
            } else {
                LoginScreen()                    
            }
        }
        .environmentObject(currentAccount)
        .environmentObject(audioPlayer)
        .environmentObject(themeManager)
        .environmentObject(settingsManager)
        .environmentObject(healthKitManager)
        .environmentObject(notificationManager)
        .preferredColorScheme(themeManager.selectedTheme)
        .onAppear {
            audioPlayer.delegate = currentAccount
        }
        .onDisappear {
            audioPlayer.delegate = nil
        }
    }
}



#Preview {
    ContentView()
}
