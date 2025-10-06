import SwiftUI
import Env
import Models

struct TrialListView: View {
    let trialData: ModuleData
    
    public var body: some View {
        PracticeListView(practices: trialData.practices)        
    }
}
