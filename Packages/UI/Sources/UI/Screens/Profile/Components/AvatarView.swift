import SwiftUI
import Env
import Models

@MainActor
struct AvatarView: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let height: CGFloat
    
    var body: some View {
        Group {
            if let avatarImage = currentAccount.avatarImage {
                Image(uiImage: avatarImage)
                    .resizable()
            } else {
                Image("avatar3")
                    .resizable()
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .clipShape(.circle)
        .frame(height: height)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 4)
        )
    }
}
