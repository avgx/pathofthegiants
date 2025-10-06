import SwiftUI
import Env
import Models

struct ProfileView: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    var body: some View {
        NavigationStack {
            Group {
                if let info = currentAccount.accountInfo {
                    List {
                        LabeledContent(content: {
                            Text("\(info.data.email)")
                        }, label: {
                            Text("email")
                        })
                        LabeledContent(content: {
                            Text("\(info.data.nickname)")
                        }, label: {
                            Text("nickname")
                        })
                        LabeledContent(content: {
                            Text("\(info.data.subscriptionLevel)")
                        }, label: {
                            Text("subscriptionLevel")
                        })                        
                    }
                } else {
                    ContentUnavailableView("no profile info", systemImage: "exclamationmark.triangle")
                }
                
            }
            .navigationTitle("Профиль")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: {
                        currentAccount.disconnect()
                    }) {
                        Text("Выход")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
