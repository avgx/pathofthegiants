import SwiftUI
import Env
import Models



struct ProfileScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    @EnvironmentObject var settingsManager: SettingsManager
    @State var showTitle = false
    @State var stat: UserStatsData? = nil
    @State var refresh = UUID()
    
    var body: some View {
        NavigationStack {
            list
                .task(id: refresh) {
                    stat = try? await currentAccount.fetchStats()
                }
                .scrollContentBackground(.hidden) // This hides the default form background
                .background(backgroundView)
        }
        .navigationViewStyle(.stack)
    }
    var list: some View {
        List {
            Section {
                info
                    .edgesIgnoringSafeArea(.top)
            }
            .listSectionMargins(.horizontal, 0)
            .listSectionMargins(.top, 0)
            .listSectionSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .onAppear {
                showTitle = false
            }
            .onDisappear {
                showTitle = true
            }
            
            Section {
                if let favoritePractice = stat?.favoritePractice {
                    if let p = currentAccount.practices?.data.first(where: { $0.id == favoritePractice.practiceID }) {
                        PracticeCard(practice: p)
                            .id(p.id)
                    } else {
                        Text("Пока отсутствует")
                    }
                } else {
                    Text("Пока отсутствует")
                }
            } header: {
                Text("Любимая практика")
            }
            
            
            Section {
                Profile.player.navigationLink
                Profile.statistics.navigationLink
                Profile.appleHealth.navigationLink
//                Profile.gameCenter.navigationLink
                Profile.notifications.navigationLink
            }
            
            Section {
                Profile.displaySettings.navigationLink
                Profile.haptic.navigationLink
            }
            
            Section {
                Profile.help.navigationLink
                Profile.info.navigationLink
            }
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
                Profile.account.navigationLink
            }
        }
        .navigationDestination(for: Profile.self, destination: { feature in
            feature.destination
        })
    }
    
    @ViewBuilder
    var info: some View {
        if let info = currentAccount.accountInfo {
            ProfileHeaderView(info: info, stat: stat)
        } else {
            ContentUnavailableView("Нет данных", systemImage: "exclamationmark.triangle").padding()
        }
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



