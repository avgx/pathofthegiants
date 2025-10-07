import SwiftUI
import Env
import Models

struct TrialListView: View {
    let trialData: ModuleData
    
    public var body: some View {
        PracticeGroupListView(practices: trialData.practices, subtitle: trialData.description)
            .scrollContentBackground(.hidden) // This hides the default form background
            .background(
                ModuleImage(module: trialData)
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            )
    }
}
