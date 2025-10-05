import SwiftUI
import Env
import Models

struct DouView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("нужно api", systemImage: "exclamationmark.triangle")
                .navigationTitle("Путь")
                .toolbarTitleDisplayMode(.inlineLarge)
        }
        .navigationViewStyle(.stack)
    }
}
