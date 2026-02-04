import SwiftUI
import Env
import Models
import LivsyToast


struct ProfileScreen: View, Loggable {
    @EnvironmentObject var currentAccount: CurrentAccount
    @EnvironmentObject var settingsManager: SettingsManager
    @State var showTitle = false
    @State var stat: UserStatsData? = nil
    @State var refresh = UUID()
    @State var notImpl = false
    @State var showLogs = false
    
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
        .lifecycleLog(String(reflecting: Self.self))
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
            } header: {
                Text("Настройки")
            }
            
            Section {
                Profile.displaySettings.navigationLink
                Profile.haptic.navigationLink
            } header: {
                Text("Интерфейс")
            }
            
            Section {
                Link(destination: URL(string: "https://vk.com/pathofthegiants")!, label: {
                    Label {
                        Text("ВКонтакте")
                        Text("@pathofthegiants")
                    } icon: {
                        Image("vk-symbol")
                    }
                })
                .buttonStyle(.plain)
                Link(destination: URL(string: "https://t.me/pathofthegiants")!, label: {
                    Label {
                        Text("Telegram")
                        Text("t.me/pathofthegiants")
                            .font(.caption2)
                    } icon: {
                        Image(systemName: "paperplane")
                    }
                })
                .buttonStyle(.plain)
                Link(destination: URL(string: "https://www.youtube.com/@pathofthegiants")!, label: {
                    Label {
                        Text("Youtube")
                        Text("@pathofthegiants")
                            .font(.caption2)
                    } icon: {
                        Image(systemName: "play.rectangle.fill")
                    }
                })
                .buttonStyle(.plain)
                Link(destination: URL(string: "https://rutube.ru/channel/57855700")!, label: {
                    Label {
                        Text("Rutube")
                        Text("channel/57855700")
                            .font(.caption2)
                    } icon: {
                        Image("rutube-symbol")
                    }
                })
                .buttonStyle(.plain)
            } header: {
                Text("Социальные сети")
            }
            
            Section {
                Link(destination: URL(string: "mailto:pathofthegiants@gmail.com")!, label: {
                    Label("Задать вопрос", systemImage: "mail")
                })
                .buttonStyle(.plain)
//                Button(action: { notImpl.toggle() }) {
//                    /// Ask a Question
//                    Label("Задать вопрос", systemImage: "mail")
//                }
                
                Button(action: {
                    notImpl.toggle()
//                    let s1 = LoggerExport.export()
//                    print(s1)
//                    
//                    let s = LoggerExport.exportEntries()
//                    print(s)
                }) {
                    ///Report a Bug
                    Label("Сообщить об ошибке", systemImage: "ladybug")
                }
                .buttonStyle(.plain)
                Button(action: { showLogs.toggle() }) {
                    Label("Отладка", systemImage: "doc")
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showLogs) {
                    LogsSheetView()
                }
                Button(action: { notImpl.toggle() }) {
                    /// Rate app
                    Label("Оценить приложение", systemImage: "star")
                }
                .buttonStyle(.plain)
                Button(action: { notImpl.toggle() }) {
                    /// Share the app
                    Label("Поделиться", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
            } header: {
                ///Support
                Text("Поддержка")
            }
            .toast(isPresented: $notImpl, message: "пока не реализовано")
            
            Section {
                Profile.help.navigationLink
                LabeledContent(content: {
                    Text(Bundle.main.versionBuild)
                }, label: {
                    Label("Версия", systemImage: "info.circle")
                })
            } header: {
                ///About
                Text("О приложении")
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
            ProfileHeaderView(info: info, stat: stat, showTitle: $showTitle)
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



