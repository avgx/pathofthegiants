import SwiftUI
import Env
import Models

extension Profile {
    struct AccountView: View {
        @EnvironmentObject var currentAccount: CurrentAccount
        
        enum Constants {
            static let avatarHeight: CGFloat = 200
        }
        
        @State var nickname = ""
        
        var body: some View {
            List {
                Section {
                    HStack {
                        Spacer()
                        avatar
                            .overlay(alignment: .bottomTrailing, content: {
                                Button(action: { print("TODO: change image") }) {
                                    Image(systemName: "pencil")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .padding(8)
                                        .glassEffect()
                                        .clipShape(.circle)
                                        .padding(8)
                                }
                            })
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                
                Section {
                    TextField("Псевдоним", text: $nickname)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                        .keyboardType(.default)
                        .submitLabel(.done)
                        .onSubmit {
                            Task {
                                try? await currentAccount.update(nickname: nickname)
                            }
                        }
                } header: {
                    Text("Псевдоним")
                }
                .onAppear {
                    nickname = currentAccount.accountInfo?.data.nickname ?? ""
                }
                
                exitButton
            }
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
        
        @ViewBuilder
        var exitButton: some View {
            Section {
                Button(action: {
                    currentAccount.disconnect()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Выйти из аккаунта")
                        Spacer()
                    }
                    .compositingGroup()
                })
                .buttonStyle(.borderedProminent)
            }
            .listRowBackground(Color.accentColor)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }
    }
}
