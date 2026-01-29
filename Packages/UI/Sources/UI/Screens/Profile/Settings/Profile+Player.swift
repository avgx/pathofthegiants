import SwiftUI
import ButtonKit
import Env
import Models

extension Profile {
    struct PlayerView: View {
        @EnvironmentObject var settingsManager: SettingsManager
        
        @State private var downloader = MP3Downloader()
        @State private var downloaderSize: Int64?
//        @State var trackProgress = false
        
        var body: some View {
            List {
                Section {
                    Toggle("Перемотка", isOn: $settingsManager.playerSeekEnabled)
                    Toggle("Сохранять прогресс", isOn: $settingsManager.playerContinueProgress)
                }
                
                Section {
                    NavigationLink(destination: {
                        PlayerCachedFilesView()
                    }, label: {
                        LabeledContent(content: {
                            if let downloaderSize {
                                Text("\(MemorySizeFormatter.format(downloaderSize))")
                            } else {
                                ProgressView()
                            }
                        }, label: {
                            Text("Кэш")
                        })
                        .task {
                            let size = try? await downloader.cacheSize()
                            //TODO: можно для каждого файла показать его размер
//                            let details = try? await downloader.cacheDetails()
//                            print(details)
                            await MainActor.run {
                                downloaderSize = size
                            }
                        }
                    })
                }
            }
        }
    }
    
    struct PlayerCachedFilesView: View {
        @EnvironmentObject var currentAccount: CurrentAccount
        
        @State private var downloader = MP3Downloader()
        @State private var uuid = UUID()
        
        var body: some View {
            List {
                //TODO: тут еще есть файлы практик "вне модулей"
                if let modules = currentAccount.regular?.data.filter({ $0.practices.count > 0 }) {
                    ForEach(modules.sorted(using: KeyPathComparator(\.id, order: .forward)), id: \.id) { module in
                        Section {
                            ForEach(module.practices, id: \.id) { practice in
                                CachedFileView(practice: practice)
                            }
                        } header: {
                            Text(module.name)
                        }
                        .id(uuid)
                    }
                }
                
                Section {
                    AsyncButton(action: {
                        try? await Task.sleep(for: .seconds(1))
                        try await downloader.clearCache()
                        uuid = UUID()
                    }) {
                        Text("Очистить")
                    }
                }
            }
        }
    }
    
    struct CachedFileView: View {
        @EnvironmentObject var currentAccount: CurrentAccount
        
        @State private var downloader = MP3Downloader()
        
        let practice: Practice
        @State var fileExistsInCache: Bool?
        
        var body: some View {
            LabeledContent(content: {
                if let fileExistsInCache {
                    if fileExistsInCache {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(.green)
                    } else {
                        AsyncButton(action: {
                            guard let mp3Url = try? await currentAccount.fetchAudioUrl(for: practice) else {
                                return
                            }
                            //TODO: конечно токен надо брать "не так". переделать
                            _ = try await downloader.simpleDownloadMP3(from: mp3Url, token: AuthToken.load())
                            let fileInCache = await downloader.fileExistsInCache(fileName: practice.audio)
                            await MainActor.run {
                                self.fileExistsInCache = fileInCache != nil
                            }
                        }) {
                            Image(systemName: "arrow.down.to.line")
                        }
                    }
                } else {
                    ProgressView()
                }
            }, label: {
                Text(practice.name)
            })
            .task {
                let fileInCache = await downloader.fileExistsInCache(fileName: practice.audio)
                await MainActor.run {
                    self.fileExistsInCache = fileInCache != nil
                }
            }
            .id(practice.id)
        }
    }
}
