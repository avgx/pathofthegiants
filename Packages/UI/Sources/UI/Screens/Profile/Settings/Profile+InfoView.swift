import SwiftUI
import Env

extension Profile {
    struct InfoView: View {
        var body: some View {
            List {
                Section {
                    LabeledContent("Версия приложения", value: Bundle.main.versionBuild)
                }
            }
        }
    }
}
