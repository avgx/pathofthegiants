import SwiftUI

extension Profile {
    struct AppleHealthView: View {
        @State var enabled = false
        
        var body: some View {
            List {
                Section {
                    Toggle("Apple Health", isOn: $enabled)
                } footer: {
                    Text("Для сохранения количества прослушанных минут медитации в Apple Health и отслеживания данных в приложении Здоровье")
                }
            }
        }
    }
}
