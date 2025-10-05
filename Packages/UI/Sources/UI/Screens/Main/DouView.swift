import SwiftUI
import Env
import Models

struct DouView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("道はありません", systemImage: "xmark")
                .navigationTitle("Путь")
                .toolbarTitleDisplayMode(.inlineLarge)
        }
        .navigationViewStyle(.stack)
    }
}
