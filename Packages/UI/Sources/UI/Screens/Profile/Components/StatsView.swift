import SwiftUI
import Env
import Models

struct StatsView: View {
    let stat: UserStatsData
    
    var body: some View {
        HStack(spacing: 20) {
            let totalPractices = stat.totalPractices
            StatView(value: "\(totalPractices)", title: LocalizeHelper.localizedPracticesString(totalPractices))
            
            let days = stat.maximumConsecutiveDaysForPractices
            StatView(value: "\(days)", title: LocalizeHelper.localizedDaysString(days))
            
            let minutes = stat.totalPracticeTime / 60
            StatView(value: "\(minutes)", title: LocalizeHelper.localizedMinutesString(minutes))
        }
    }
}
