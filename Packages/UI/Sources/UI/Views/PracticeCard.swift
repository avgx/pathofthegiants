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
            VStack(alignment: .leading) {
                Text(practice.name)
                Text(practice.briefDescription)
                    .font(.footnote)
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
