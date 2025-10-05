import SwiftUI
import Env
import Models

struct PracticeCard: View {
    let practice: Practice
    
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
    }
}
