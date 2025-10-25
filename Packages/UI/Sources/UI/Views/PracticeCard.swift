import SwiftUI
import Env
import Models

struct PracticeCard: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let practice: Practice
    @State var fullscreen = false
    
    var body: some View {
        HStack(spacing: 16) {
            PracticeImage(practice: practice)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay {
                    if practice.subscriptionLevel > 0 {
                        Image(systemName: "crown.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 16, height: 16)
                            .offset(x: 22 - 8/2, y: -22 + 8/2)
                    }
                }
            VStack(alignment: .leading) {
                Text(practice.name)
                Text(practice.briefDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            if let p = currentAccount.tracker.progress[practice.id] {
                Spacer()
                ProgressBadge(progress: .constant(p / Double(practice.audioDuration)))
            }
        }
        
        .onTapGesture {
            fullscreen.toggle()
        }
        .fullScreenCover(isPresented: $fullscreen) {
            NavigationStack {
                PracticeScreen(practice: practice)
            }
            .navigationViewStyle(.stack)
        }
    }
}
