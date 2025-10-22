import SwiftUI
import Env
import Models

@MainActor
struct ProfileHeaderView: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    enum Constants {
        static let headerHeight: CGFloat = 200
        static let avatarHeight: CGFloat = 80
    }
    
    let info: AccountInfo
    let stat: UserStatsData?
    
    var body: some View {
        VStack(alignment: .leading) {
            headerImage
                .ignoresSafeArea()
                .overlay {
                    VStack(alignment: .leading) {
                        Spacer()
                        HStack {
                            AvatarView(height: Constants.avatarHeight)
                                .offset(y: 40)
                            Spacer()
                        }
                    }
                    .padding(.leading, 16)
                }
            HStack {
                Spacer()
                if let stat {
                    StatsView(stat: stat)
                } else {
                    ProgressView()
                }
            }
            .padding(.horizontal)
            HStack {
                nick
                Spacer()
            }
            .padding(.horizontal)
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
    
    
}
