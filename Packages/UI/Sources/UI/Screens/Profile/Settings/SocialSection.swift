import SwiftUI

struct SocialSection: View {
    
    var body: some View {
        Section {
            Link(destination: URL(string: "https://vk.com/pathofthegiants")!, label: {
                Label {
                    Text("ВКонтакте")
                    Text("@pathofthegiants")
                } icon: {
                    Image("vk-symbol")
                }
            })
            .buttonStyle(.plain)
            Link(destination: URL(string: "https://t.me/pathofthegiants")!, label: {
                Label {
                    Text("Telegram")
                    Text("t.me/pathofthegiants")
                        .font(.caption2)
                } icon: {
                    Image(systemName: "paperplane")
                }
            })
            .buttonStyle(.plain)
            Link(destination: URL(string: "https://www.youtube.com/@pathofthegiants")!, label: {
                Label {
                    Text("Youtube")
                    Text("@pathofthegiants")
                        .font(.caption2)
                } icon: {
                    Image(systemName: "play.rectangle.fill")
                }
            })
            .buttonStyle(.plain)
            Link(destination: URL(string: "https://rutube.ru/channel/57855700")!, label: {
                Label {
                    Text("Rutube")
                    Text("channel/57855700")
                        .font(.caption2)
                } icon: {
                    Image("rutube-symbol")
                }
            })
            .buttonStyle(.plain)
        } header: {
            Text("Социальные сети")
        }
    }
}

