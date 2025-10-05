import SwiftUI
import Env
import ButtonKit

public struct LoginScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    @State var user: String = ""
    @State var pass: String = ""
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("user", text: $user)
                    TextField("pass", text: $pass)
                }
                    
                loginButton
                
                Section {
                    HStack(spacing: 16) {
                        Spacer()
                        Text("or")
                        Spacer()
                    }
                    .compositingGroup()
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                
                trialButton
                
            }
            .navigationTitle("Путь великанов")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Help", systemImage: "questionmark", action: { })
                    
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    public var loginButton: some View {
        Section {
            AsyncButton(action: {
                try await currentAccount.setAccount(user: user, pass: pass)
            }, label: {
                HStack {
                    Spacer()
                    Text("Login")
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
    public var trialButton: some View {
        Section {
            AsyncButton(action: {
                try await currentAccount.setTrial()
            }, label: {
                HStack {
                    Spacer()
                    Text("Trial")
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
}

#Preview {
    LoginScreen()
        .environmentObject(CurrentAccount.shared)
}
