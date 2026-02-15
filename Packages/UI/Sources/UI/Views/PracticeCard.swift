import SwiftUI
import Env
import Models

struct PracticeCard: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    @EnvironmentObject var tracker: SessionTracker
    
    let practice: Practice
    
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
                            .foregroundStyle(Color.purple)
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
            
            Spacer()
        }
        .overlay(alignment: .topTrailing) {
            if let progress = tracker.progress[practice.id] {
                ProgressBadge(progress: .constant(progress / Double(practice.audioDuration)))
                    .foregroundStyle(Color.accentColor)
                    .font(.body)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            tracker.start(practice: practice)
            HapticManager.shared.fireHaptic(.buttonPress)
        }
    }
}
