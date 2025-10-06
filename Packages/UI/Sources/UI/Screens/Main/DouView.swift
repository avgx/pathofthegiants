import SwiftUI
import Env
import Models

struct DouView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("нужно api", systemImage: "exclamationmark.triangle")
                .navigationTitle("Пути")
                .toolbarTitleDisplayMode(.inlineLarge)
        }
        .navigationViewStyle(.stack)
    }
}
