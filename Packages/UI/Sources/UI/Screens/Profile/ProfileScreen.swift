import SwiftUI
import Env
import Models
import LivsyToast
import DeviceKit

struct ProfileScreen: View, Loggable {
    @EnvironmentObject var currentAccount: CurrentAccount
    @EnvironmentObject var settingsManager: SettingsManager
    @State var showTitle = false
    @State var stat: UserStatsData? = nil
    @State var refresh = UUID()
    @State var notImpl = false
    
    var body: some View {
#if DEBUG
        let _ = Self._printChanges() // Place it here
#endif
        NavigationStack {
            list
                .task(id: refresh) {
                    stat = nil
                    try? await Task.sleep(for: .seconds(1))
                    stat = try? await currentAccount.fetchStats()
                }
                .scrollContentBackground(.hidden) // This hides the default form background
                .background(backgroundView)
        }
        .navigationViewStyle(.stack)
        .lifecycleLog(String(reflecting: Self.self))
    }
    var list: some View {
        List {
            Section {
                ProfileHeaderView(info: currentAccount.accountInfo, stat: stat, showTitle: $showTitle)
                    .edgesIgnoringSafeArea(.top)
            }
            .listSectionMargins(.horizontal, 0)
            .listSectionMargins(.top, 0)
            .listSectionSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            
            FavoritePracticeSection(stat: stat)
            
            Section {
                ProfileRoute.player.navigationLink
                ProfileRoute.statistics.navigationLink
                ProfileRoute.appleHealth.navigationLink
                ProfileRoute.notifications.navigationLink
            } header: {
                Text("Настройки")
            }
            
            Section {
                ProfileRoute.displaySettings.navigationLink
                ProfileRoute.haptic.navigationLink
            } header: {
                Text("Интерфейс")
            }
            
            SocialSection()
            SupportSection()
            AboutSection()
        }
        .refreshable {
            refresh = UUID()
        }
        .edgesIgnoringSafeArea(.top)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            if showTitle {
                ToolbarItem(placement: .title, content: {
                    HStack {
                        AvatarView(height: 44)
                        if let nickname = currentAccount.accountInfo?.data.nickname {
                            Text("@\(nickname)")
                        }
                    }
                })
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                ProfileRoute.account.navigationLink
            }
        }
        .navigationDestination(for: ProfileRoute.self, destination: { feature in
            feature.destination
        })
    }

    @ViewBuilder
    private var backgroundView: some View {
        if settingsManager.moduleBackground {
            ZStack {
                Color(.systemGroupedBackground)
                    .opacity(0.24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                
                MainBackground()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.7)
                    .blur(radius: CGFloat(settingsManager.moduleBackgroundBlur))
                    .ignoresSafeArea()
            }
        } else {
            // Обязательно нужен else
            // Лучшие варианты для дефолтного фона:
            Color(.systemGroupedBackground) // 👈 Самый точный аналог дефолтного
                .ignoresSafeArea()
        }
    }
}



