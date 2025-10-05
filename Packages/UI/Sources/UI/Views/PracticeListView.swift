import SwiftUI
import Env
import Models

struct PracticeListView: View {
    let practices: [Practice]
    
    var body: some View {
        List {
            ForEach(practices) { practice in
                PracticeCard(practice: practice)
            }
        }
    }
}
