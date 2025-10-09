import SwiftUI
import Env
import ButtonKit

struct LoginScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    @AppStorage("user") var savedUser = ""
    
    @State var user: String = ""
    @State var pass: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                form
                    .onAppear {
                        user = savedUser
                    }
                    .onDisappear {
                        savedUser = user
                    }
            }
            .scrollContentBackground(.hidden) // This hides the default form background
            .background(MainBackground())
            .navigationTitle("Путь великанов")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    var form: some View {
        List {
            Section {
                TextField("email", text: $user, prompt: Text("email"))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.default)
                    .submitLabel(.next)
                SecureField("password", text: $pass, prompt: Text("пароль"))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textContentType(.password)
                    .keyboardType(.default)
                    .submitLabel(.done)
            } header: {
                HStack {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Spacer()
                }
            }
            
            loginButton
            trialButton
            
        }
    }
    
    @ViewBuilder
    var loginButton: some View {
        Section {
            AsyncButton(action: {
                try await currentAccount.setAccount(user: user, pass: pass)
                try await currentAccount.connect()
            }, label: {
                HStack {
                    Spacer()
                    Text("Войти")
                    Spacer()
                }
                .compositingGroup()
            })
            .throwableButtonStyle(.shake)
            .allowsHitTestingWhenLoading(false)
            .asyncButtonStyle(.overlay)
            .buttonStyle(.borderedProminent)
        }
        .listRowBackground(Color.accentColor)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    var trialButton: some View {
        Section {
            AsyncButton(action: {
                try await currentAccount.setTrial()
            }, label: {
                HStack {
                    Spacer()
                    Text("Практики вне Пути")
                    Spacer()
                }
                .compositingGroup()
            })
            .throwableButtonStyle(.shake)
            .allowsHitTestingWhenLoading(false)
            .asyncButtonStyle(.overlay)
            .buttonStyle(.borderedProminent)
        } header: {
            HStack(spacing: 16) {
                Spacer()
                Text("или посмотреть")
                Spacer()
            }
            .compositingGroup()
            .padding(.bottom, 16)
        } footer: {
            HStack(spacing: 16) {
                Spacer()
                Text("Эти практики доступны без регистрации.")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .listRowBackground(Color.accentColor)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
    }
}

#Preview {
    LoginScreen()
        .environmentObject(CurrentAccount.shared)
}
