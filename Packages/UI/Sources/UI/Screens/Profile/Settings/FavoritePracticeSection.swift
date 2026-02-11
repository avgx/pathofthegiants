import SwiftUI
import Env
import Models

struct FavoritePracticeSection: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    let stat: UserStatsData?
    
    var body: some View {
        Section {
            if let stat {
                if let favoritePractice = stat.favoritePractice {
                    if let p = currentAccount.practices?.data.first(where: { $0.id == favoritePractice.practiceID }) {
                        PracticeCard(practice: p)
                            .id(p.id)
                    } else {
                        Text("Пока отсутствует")
                    }
                } else {
                    Text("Пока отсутствует")
                }
            } else {
                if let p = currentAccount.practices?.data.first {
                    PracticeCard(practice: p)
                        .redacted(reason: .placeholder)
                        .disabled(true)
                } else {
                    Text("Пока отсутствует")
                        .redacted(reason: .placeholder)
                }
            }
        } header: {
            Text("Любимая практика")
        }
    }
}
