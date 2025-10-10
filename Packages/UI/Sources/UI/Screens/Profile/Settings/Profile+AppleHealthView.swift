import SwiftUI

extension Profile {
    struct AppleHealthView: View {
        @State var enabled = false
        
        var body: some View {
            List {
                Section {
                    Toggle("Apple Health", isOn: $enabled)
                }
            }
        }
    }
}
