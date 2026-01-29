import SwiftUI
import Env

struct SplashScreen: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    @Binding var complete: Bool
    
    var body: some View {
        VStack {
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("path")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        )
        .onAppear {
            Task {
                bgMain = try? await currentAccount.fetchBgMain()
                
                do {
                    try await currentAccount.connect()
                } catch {
                    print(error.localizedDescription)
                }
                
                withAnimation {
                    complete = true
                }
            }
        }
    }
}
