import SwiftUI

struct AboutSection: View {
    
    var body: some View {
        Section {
            Profile.help.navigationLink
            
            Link(destination: URL(string: "https://путьвеликанов.рф/politika_konfidentsialnosti")!, label: {
                Label("Политика конфиденциальности", systemImage: "text.document")
            })
            .buttonStyle(.plain)

            Link(destination: URL(string: "https://путьвеликанов.рф/polzovatelskoe_soglashenie")!, label: {
                Label("Пользовательское соглашение", systemImage: "text.document")
            })
            .buttonStyle(.plain)

            LabeledContent(content: {
                Text(Bundle.main.versionBuild)
            }, label: {
                Label("Версия", systemImage: "info.circle")
            })
        } header: {
            ///About
            Text("О приложении")
        }
    }
}
