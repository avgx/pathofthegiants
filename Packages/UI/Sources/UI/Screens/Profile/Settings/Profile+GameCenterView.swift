import SwiftUI

extension Profile {
    struct GameCenterView: View {
        @State var enabled = false
        
        var body: some View {
            List {
                Section {
                    Toggle("Game Center", isOn: $enabled)
                }
            }
        }
    }
}
