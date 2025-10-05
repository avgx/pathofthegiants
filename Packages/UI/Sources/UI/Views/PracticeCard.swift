import SwiftUI
import Env
import Models

struct PracticeCard: View {
    let practice: Practice
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(practice.name)
            Text(practice.briefDescription)
                .font(.footnote)
        }
    }
}
