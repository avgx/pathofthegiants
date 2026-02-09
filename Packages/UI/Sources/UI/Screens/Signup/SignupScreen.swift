import SwiftUI
import Env
import Models
import ButtonKit
import Get
import LivsyToast

struct SignupScreen: View, Loggable {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) var isPresented
    @EnvironmentObject var currentAccount: CurrentAccount
    
    @State var email: String = ""
    @State var pass: String = ""
    
    @State var errorString = ""
    @State var emailError = ""
    @State var isPasswordVisible = false
    @State var toastCheckEmail = false
    
    var isEmailValid: Bool {
        emailError.isEmpty && !email.isEmpty
    }
    var isPasswordValid: Bool {
        pass.count >= 6 && !pass.contains(" ") && pass.contains(where: { $0.isNumber })
    }
    
    var body: some View {
        NavigationStack {
            form
            .scrollBounceBehavior(.basedOnSize)
            //.scrollContentBackground(.hidden) // This hides the default form background
            //.background(MainBackground())
            .navigationTitle("Регистрация")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    if isPresented {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                ToolbarItemGroup(placement: .confirmationAction) {
                    signupButton
                }
            }
            .toast(
                isPresented: $toastCheckEmail,
                duration: 2,
                edge: .bottom
            ) {
                HStack(spacing: 12) {
                    Image(systemName: "mail")
                    
                    Text("Письмо с подтверждением регистрации отправлено")
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .navigationViewStyle(.stack)
        .lifecycleLog(String(reflecting: Self.self))
    }
    
    @ViewBuilder
    var form: some View {
        List {
            Section {
                TextField("email", text: $email, prompt: Text("email"))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .keyboardType(.default)
                    .submitLabel(.next)
                    .disableAutocorrection(true)
                    .onChange(of: email) { _ in
                        validateEmail()
                    }
                //                SecureField("Введите пароль", text: $pass, prompt: Text("пароль"))
                //                    .autocorrectionDisabled()
                //                    .textInputAutocapitalization(.never)
                //                    .textContentType(.password)
                //                    .keyboardType(.default)
                //                    .submitLabel(.done)
                
                HStack {
                    if isPasswordVisible {
                        TextField("пароль", text: $pass)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .textContentType(.password)
                            .keyboardType(.default)
                            .submitLabel(.done)
                    } else {
                        SecureField("пароль", text: $pass, prompt: Text("пароль"))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .textContentType(.password)
                            .keyboardType(.default)
                            .submitLabel(.done)
                    }
                    
                    // Кнопка видимости пароля
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                
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
                VStack(alignment: .leading, spacing: 4) {
                    if !errorString.isEmpty {
                        Text(errorString)
                            .foregroundStyle(.red)
                    } else if !emailError.isEmpty {
                        Text(emailError)
                            .foregroundStyle(.red)
                    } else {
                        RequirementView(
                            text: "Email",
                            isMet: isEmailValid
                        )
                        RequirementView(
                            text: "Пароль не менее 6 символов",
                            isMet: pass.count >= 6
                        )
                        RequirementView(
                            text: "Пароль без пробелов",
                            isMet: !pass.isEmpty && !pass.contains(" ")
                        )
                        RequirementView(
                            text: "Пароль содержит хотя бы одну цифру",
                            isMet: pass.contains(where: { $0.isNumber })
                        )
                        if isEmailValid && isPasswordValid {
                            Text("Регистрируясь, вы соглашаетесь с [***лицензионным соглашением***](https://pathofthegiants.ru/agreement) и [***политикой конфиденциальности***](https://путьвеликанов.рф/politika_konfidentsialnosti)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .font(.caption)
            }
            
//            signupButton
            
//            trialButton
        }
    }
    
    @ViewBuilder
    var signupButton: some View {
//        Section {
            AsyncButton(action: {
                
                do {
                    errorString = ""
                    try await currentAccount.signup(user: email, pass: pass)
                    toastCheckEmail.toggle()
                    dismiss()
                } catch CustomError.unacceptableStatusCode(let code, let text, _) {
                    logger.error("\(code, privacy: .public) \(text, privacy: .public)")
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
//                HStack {
//                    Spacer()
//                    Text("Зарегистрироваться")
//                    Spacer()
//                }
//                .compositingGroup()
//                .padding(8)
                Image(systemName: "checkmark")
            })
            .throwableButtonStyle(.shake)
            .allowsHitTestingWhenLoading(false)
            .asyncButtonStyle(.overlay)
            .buttonStyle(.borderedProminent)
            .disabled(!isEmailValid || !isPasswordValid)
//        }
//        .listRowBackground(Color.clear)
//        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//        .listRowSeparator(.hidden)
    }
    
    
    
    func validateEmail() {
        let emailMaxLength = 32
        let emailRegex = #"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        // Автоматическое удаление пробелов
        email = email.replacingOccurrences(of: " ", with: "")
        
        // Ограничение максимальной длины
        if email.count > emailMaxLength {
            email = String(email.prefix(emailMaxLength))
        }
        
        // Валидация формата email
        if email.isEmpty {
            emailError = ""
            return
        }
        
        if email.count < 6 {
            emailError = "Email должен содержать минимум 6 символов"
            return
        }
        
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPredicate.evaluate(with: email) {
            emailError = "Неверный формат email"
        } else {
            emailError = ""
        }
    }
    
    struct RequirementView: View {
        let text: String
        let isMet: Bool
        
        var body: some View {
            HStack {
                Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isMet ? .green : .gray)
                Text(text)
                    .foregroundColor(isMet ? .green : .gray)
            }
        }
    }
}

#Preview {
    SignupScreen()
        .environmentObject(CurrentAccount.shared)
}
