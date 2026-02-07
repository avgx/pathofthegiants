import SwiftUI
import Env
import Models
import Stretchable
import LivsyToast

@MainActor
struct ProfileHeaderView: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    enum Constants {
        static let headerHeight: CGFloat = 200
        static let avatarHeight: CGFloat = 80
    }
    
    let info: AccountInfo?
    let stat: UserStatsData?
    @Binding var showTitle: Bool
    
    @State var notImpl = false
    
    var body: some View {
        VStack(alignment: .leading) {
            headerImage
                .ignoresSafeArea()
                .stretchable()
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
            .overlay(alignment: .top) {
                GeometryReader { proxy in
                    Color.clear
                        .frame(height: 1)
                        .onChange(of: proxy.frame(in: .global).minY) { _, newY in
                            // Если элемент ушёл за верхнюю границу экрана
                            if newY < 0 {
                                showTitle = true
                            } else {
                                showTitle = false
                            }
                        }
                }
            }
            
            HStack {
                nick
                Spacer()
                subscription
                    .padding()
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
        Text("@\(info?.data.nickname ?? "??????")")
            .font(.title2)
            .fontWeight(.bold)
    }
    
    @ViewBuilder
    var subscription: some View {
        if let info, info.data.subscriptionLevel == 1 {
            VStack {
                Text("Подписка")
                    .fontWeight(.bold)
                if info.data.endDate != nil {
                    Text("до \(info.data.formattedEndDate)")
                        .font(.caption2)
                }
            }
        } else {
            Button(action:{ notImpl.toggle() }) {
                Text("Подписка")
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .toast(isPresented: $notImpl, message: "пока не реализовано")
        }
    }
}
