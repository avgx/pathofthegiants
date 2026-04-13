import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareButton: View {
    @State private var showingShareSheet = false
    let appStoreURL = "https://apps.apple.com/app/\(Bundle.main.appStoreId)"
    
    var body: some View {
        Button(action: { showingShareSheet = true }) {
            Label("Share App", systemImage: "square.and.arrow.up")
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [URL(string: appStoreURL)!])
        }
    }
}
