import SwiftUI
import Env
import ButtonKit
import Get
import Models
import Env

struct LoginScreen: View, Loggable {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    @AppStorage("user") var savedUser = ""
    
    @State var user: String = ""
    @State var pass: String = ""
    
    @State var signup = false
    @State var restore = false
    @State var errorString = ""
    
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
            .sheet(isPresented: $restore, content: {
                RestoreScreen(email: $user, pass: $pass)
            })
        }
        .navigationViewStyle(.stack)
        .lifecycleLog(String(reflecting: Self.self))
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
            } footer: {
                if !errorString.isEmpty {
                    Text(errorString)
                        .foregroundStyle(.red)
                }
            }
            
            loginButton
            
            
            Section {
                Button(action: { signup.toggle() }) {
                    HStack {
                        Spacer()
                        Text("Зарегистрироваться")
                            .minimumScaleFactor(0.7)
                        Spacer()
                    }
                    .compositingGroup()
                    .padding(8)
                }
                .buttonStyle(.glass)
            } header: {
                HStack {
                    Spacer()
                    Text("Нет аккаунта?")
                        .font(.footnote)
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
                do {
                    errorString = ""
                    try await currentAccount.setAccount(user: user, pass: pass)
                    try await currentAccount.connect()
                } catch CustomError.unacceptableStatusCode(let code, let text, _) {
                    print(text)
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: Data(text.utf8)) {
                        print("Код ошибки: \(errorResponse.error.code)")
                        print("Сообщение: \(errorResponse.error.message)")
                        errorString = errorResponse.error.message
                    } else {
                        errorString = ErrorCode.unknown.localizedMessage //"Неизвестная ошибка\n\(text)"
                    }
                    throw URLError(.init(rawValue: code))
                } catch {
                    print(error)
                    throw error
                }
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
            .buttonStyle(.glassProminent)
        } footer: {
            Button(action: { restore.toggle() }) {
                HStack {
                    Spacer()
                    Text("Забыли пароль?")
                    Spacer()
                }
                .compositingGroup()
                .padding(8)
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)
            .padding(.bottom, 8)
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
