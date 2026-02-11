import SwiftUI
import Env
import Models

struct StatsView: View {
    let stat: UserStatsData?
    
    var body: some View {
        HStack(spacing: 8) {
            let totalPractices = stat?.totalPractices ?? 0
            StatView(value: "\(totalPractices)", title: LocalizeHelper.localizedPracticesString(totalPractices))
            
            let days = stat?.maximumConsecutiveDaysForPractices ?? 0
            StatView(value: "\(days)", title: LocalizeHelper.localizedDaysString(days))
            
            let minutes = (stat?.totalPracticeTime ?? 0) / 60
            StatView(value: "\(minutes)", title: LocalizeHelper.localizedMinutesString(minutes))
        }
        .redacted(reason: stat == nil ? .placeholder : [])
    }
}
