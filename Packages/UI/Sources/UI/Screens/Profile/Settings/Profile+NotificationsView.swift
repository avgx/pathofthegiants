import SwiftUI

extension Profile {
    struct NotificationsView: View {
        @State var enabled = false
        
        var body: some View {
            List {
                Section {
                    Toggle("Push Notifications", isOn: $enabled)
                }
            }
        }
    }
}
