import SwiftUI
import Models
import Api
import Get

@MainActor
public class CurrentAccount: ObservableObject {
    
    @Published public private(set) var isTrial: Bool = false
    @Published public private(set) var token: AuthToken?
    @Published public private(set) var accountInfo: AccountInfo?
    @Published public private(set) var practices: Practices?
    @Published public private(set) var trial: Trial?
    @Published public private(set) var regular: Regular?
    @Published public var currentPractice: Practice?
    
    public static let shared = CurrentAccount()
    
    private var http: HttpClient5?
    
    private init() {
        
    }
    
    /// Отключиться
    public func disconnect() {
        isTrial = false
        token = nil
        AuthToken.delete()
        accountInfo = nil
        trial = nil
        regular = nil
        practices = nil
    }
    
    /// Подключиться к аккаунту `account`
    public func setAccount(user: String, pass: String) async throws {
        let http = HttpClient5(baseURL: Api.baseURL)
        
        let auth = try await http.send(Api.accountLogin(user: user, password: pass))
        auth.value.data.token.save()
    }
    
    public func connect() async throws {
        guard let token = AuthToken.load() else {
            throw AppError.tokenNotFound
        }
        
        let http2 = HttpClient5(baseURL: Api.baseURL, authorization: .bearer(token), sessionConfiguration: .withCache)
        let infoResponse = try await http2.send(Api.accountInfo())
        let practicesResponse = try await http2.send(Api.practices())
        let regularResponse = try await http2.send(Api.modulesRegular())
        
        self.regular = regularResponse.value
        self.accountInfo = infoResponse.value
        self.practices = practicesResponse.value
        
        self.http = http2
        self.token = token
    }
    
    /// Подключиться `попробовать` без аккаунта
    public func setTrial() async throws {
        let http = HttpClient5(baseURL: Api.baseURL, sessionConfiguration: .withCache)
        
        let trialResponse = try await http.send(Api.modulesTrial())
        self.trial = trialResponse.value
        
        self.http = http
        isTrial = true
    }
    
    public func fetchBgMain() async throws -> UIImage {
        let http = HttpClient5(baseURL: Api.baseURL, sessionConfiguration: .withCache)
        
        let imageData = try await http.send(Api.bgMain())
        let image = UIImage(data: imageData.data) ?? UIImage()
        return image
    }
    
    public func fetchImage(for image: String) async throws -> UIImage {
        guard let http else { return UIImage() }
        
        let imageData = try await http.send(Api.file(name: image))
        let image = UIImage(data: imageData.data) ?? UIImage()
        return image
    }
    
    public func fetchAudio(for practice: Practice) async throws -> Data? {
        guard let http else { return nil }
        
        let audioData = try await http.send(Api.file(name: practice.audio))
        return audioData.data
    }
    
    public func fetchStats() async throws -> UserStatsData? {
        guard let http else { return nil }
        
        let statsData = try await http.send(Api.stats())
        return statsData.value.data
    }
    
    public func update(nickname: String) async throws {
        guard let http else { return }
        
        _ = try await http.send(Api.profile(nickname: nickname))
        
        self.accountInfo = try await http.send(Api.accountInfo()).value
    }
}

extension CurrentAccount: AudioPlayerDelegate {
    public func audioPlayerListenedTime(duration: TimeInterval) {
        print("CurrentAccount audioPlayerListenedTime \(duration)")
        guard let http else { return }
        guard let currentPractice else { return }
        
        var progress = 0
        switch SettingsManager.shared.statisticsUpdate {
        case .seconds:
            progress = Int(duration)
        case .minutes:
            progress = Int(duration / 60) * 60
        case .complete:
            if abs(currentPractice.audioDuration - Int(duration)) < 1 {
                progress = Int(duration)
            }
        }
        
        guard progress > 0 else { return }
        
        Task {
            _ = try? await http.send(Api.postProgress(practiceId: currentPractice.id, seconds: duration))
        }
    }
    
    public func audioPlayerDidFinishPlaying(duration: TimeInterval) {
        print("CurrentAccount audioPlayerDidFinishPlaying \(duration)")
        
        guard let http else { return }
        guard let currentPractice else { return }
        
        Task {
            _ = try? await http.send(Api.postCompleted(practiceId: currentPractice.id, seconds: duration))
        }
    }
    
    
}
