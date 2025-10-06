import SwiftUI
import Env
import Models

struct PracticeCard: View {
    let practice: Practice
    @State var fullscreen = false
    
    var body: some View {
        HStack(spacing: 16) {
            PracticeImage(practice: practice)
                .frame(width: 44, height: 44)
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
