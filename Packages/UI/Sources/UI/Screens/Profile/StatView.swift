import SwiftUI

struct StatView: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
