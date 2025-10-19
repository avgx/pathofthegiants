import SwiftUI
import Env

extension Profile {
    struct InfoView: View {
        var body: some View {
            List {
                Section {
                    LabeledContent("Версия приложения", value: Bundle.main.versionBuild)
                } footer: {
                    HStack(spacing: 16) {
                        Spacer()
                        Link(destination: URL(string: "https://vk.com/pathofthegiants")!, label: {
                            Label("@pathofthegiants", image: "vk")
                        })
                        Spacer()
                        Link(destination: URL(string: "https://t.me/pathofthegiants")!, label: {
                            Label("t.me/pathofthegiants", image: "tg")
                        })
                        Spacer()
                        Link(destination: URL(string: "mailto:pathofthegiants@gmail.com")!, label: {
                            Label("pathofthegiants@gmail.com", image: "email")
                        })
                        Spacer()
                    }
                    .labelStyle(.iconOnly)
                    .padding()
                }
            }
        }
    }
}
