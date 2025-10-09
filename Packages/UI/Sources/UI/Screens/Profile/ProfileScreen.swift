import SwiftUI
import Env
import Models

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

struct ProfileScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    @State var showTitle = false
    @State var stat: UserStatsData? = nil
    @State var refresh = UUID()
    
    var body: some View {
        NavigationStack {
            list
                .task(id: refresh) {
                    stat = try? await currentAccount.fetchStats()
                }
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
                }
            } header: {
                Text("Любимая практика")
            }
            
            
            Section {
                NavigationLink(value: Profile.notifications) {
                    Label("Уведомления", systemImage: "bell.badge")
                }
                NavigationLink(value: Profile.appleHealth) {
                    Label("Apple Health", systemImage: "brain.head.profile")
                }
                NavigationLink(value: Profile.gameCenter) {
                    Label("Game Center", systemImage: "laurel.leading.laurel.trailing")
                }
            }
            
            Section {
                NavigationLink(value: Profile.displaySettings) {
                    Label("Оформление", systemImage: "wand.and.sparkles")
                }
            }
            
            Section {
                NavigationLink(value: Profile.help) {
                    Label("Помощь", systemImage: "questionmark.circle")
                }
                
                NavigationLink(value: Profile.info) {
                    Label("О приложении", systemImage: "info.circle")
                }
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
                    Image("avatar4")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .clipShape(.circle)
                        .frame(height: 44)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                        )
                        if let nickname = currentAccount.accountInfo?.data.nickname {
                            Text("@\(nickname)")
                        }
                    }
                })
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink(value: Profile.account) {
                    Label("Аккаунт", systemImage: "pencil")
                }
            }
        }
        .navigationDestination(for: Profile.self, destination: { feature in
            VStack {
                Text("\(feature.rawValue)")
                Spacer()
                if case .account = feature {
                    Button(role: .destructive, action: {
                        currentAccount.disconnect()
                    }) {
                        Label("Выход", systemImage: "rectangle.portrait.and.arrow.forward")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("\(feature.rawValue)")
        })
    }
    
    @ViewBuilder
    var info: some View {
        if let info = currentAccount.accountInfo {
            ProfileInfo(info: info, stat: stat)
        } else {
            ContentUnavailableView("Нет данных", systemImage: "exclamationmark.triangle").padding()
        }
    }
}



