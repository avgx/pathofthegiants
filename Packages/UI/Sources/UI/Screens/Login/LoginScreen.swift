import SwiftUI
import Env
import ButtonKit

struct LoginScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    @AppStorage("user") var savedUser = ""
    
    @State var user: String = ""
    @State var pass: String = ""
    
    @State var signup = false
    
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
            .sheet(isPresented: $signup, content: {
                SignupScreen()
            })
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
            
            
            Section {
                HStack {
                    Spacer()
                    Text("Нет аккаунта?")
                        .font(.footnote)
                    
                    Button(action: { signup.toggle() }) {
                        Text("Зарегистрироваться")
                            .minimumScaleFactor(0.7)
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
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
                .padding(8)
            })
            .throwableButtonStyle(.shake)
            .allowsHitTestingWhenLoading(false)
            .asyncButtonStyle(.overlay)
            .buttonStyle(.borderedProminent)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
    }
    
    
}

#Preview {
    LoginScreen()
        .environmentObject(CurrentAccount.shared)
}
