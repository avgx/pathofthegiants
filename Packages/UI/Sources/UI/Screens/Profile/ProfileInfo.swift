import SwiftUI
import Env
import Models

@MainActor
struct ProfileInfo: View {
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
                            avatar
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
