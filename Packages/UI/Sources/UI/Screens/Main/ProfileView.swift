import SwiftUI
import Env
import Models

struct ProfileView: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    content
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.top)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ellipsisMenu
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    var ellipsisMenu: some View {
        Menu(content: {
            Section {
                Button(action: { }) {
                    Label("Обновить", systemImage: "arrow.counterclockwise")
                }
                
                Button(action: { }) {
                    Label("Изменить имя", systemImage: "pencil")
                }
                
                Button(action: { }) {
                    Label("Apple health", systemImage: "apple.meditate")
                }
            }
            Section {
                Button(role: .destructive, action: {
                    currentAccount.disconnect()
                }) {
                    Label("Выход", systemImage: "rectangle.portrait.and.arrow.forward")
                }
            }
        }, label: {
            Image(systemName: "ellipsis")
        })
    }
    
    @ViewBuilder
    var content: some View {
        if let info = currentAccount.accountInfo {
            ProfileHeaderView(info: info)
        } else {
            ContentUnavailableView("Нет данных", systemImage: "exclamationmark.triangle").padding()
        }
    }
}

@MainActor
struct ProfileHeaderView: View {
    enum Constants {
        static let headerHeight: CGFloat = 200
        static let avatarHeight: CGFloat = 80
    }
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let info: AccountInfo
    
    @State var stat: UserStatsData? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            headerImage
                .ignoresSafeArea()
                .overlay {
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            avatar
                                .offset(y: 40)
                            Spacer()
                        }
                    }
                    .padding(.leading, 16)
                }
            HStack {
                nick
                    .padding(.top, 56)
                    .padding(.leading, 16)
                Spacer()
                HStack(spacing: 20) {
                    StatView(value: "\((stat?.totalPracticeTime ?? 0)/60)", title: "минут")
                    StatView(value: "\(stat?.maximumConsecutiveDaysForPractices ?? 0)", title: "дней подряд")
                    StatView(value: "\(stat?.totalPractices ?? 0)", title: "практик")
                }
                .task {
                    stat = try? await currentAccount.fetchStats()
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var headerImage: some View {
        Image("background1")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: Constants.headerHeight)
            .clipped()
    }
    
    @ViewBuilder
    var nick: some View {
        Text("@\(info.data.nickname)")
            .font(.title2)
            .fontWeight(.bold)
    }
    
    @ViewBuilder
    var avatar: some View {
        Image("avatar4")
            .resizable()
            .aspectRatio(1.0, contentMode: .fit)
            .clipShape(.circle)
            .frame(height: Constants.avatarHeight)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
            )
    }
}
