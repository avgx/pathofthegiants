import SwiftUI
import Models
import Api
import Get

@MainActor
//@Observable
public class CurrentAccount: ObservableObject {
    
    @Published public private(set) var isTrial: Bool = false
    @Published public private(set) var account: Auth?
    @Published public private(set) var accountInfo: AccountInfo?
    @Published public private(set) var practices: Practices?
    @Published public private(set) var trial: Trial?
    @Published public private(set) var regular: Regular?
    
    public static let shared = CurrentAccount()
    
    private var http: HttpClient5?
    
    private init() {
        
    }
    
    /// Отключиться
    public func disconnect() {
        isTrial = false
        account = nil
        accountInfo = nil
        trial = nil
        regular = nil
        practices = nil
    }
    
    /// Подключиться к аккаунту `account`
    public func setAccount(user: String, pass: String) async throws {
        let http = HttpClient5(baseURL: Api.baseURL)
        
        let auth = try await http.send(Api.accountLogin(user: user, password: pass))
        
        let http2 = HttpClient5(baseURL: Api.baseURL, authorization: .bearer(auth.value.data.token), sessionConfiguration: .withCache)
        let infoResponse = try await http2.send(Api.accountInfo())
        let practicesResponse = try await http2.send(Api.practices())
        let regularResponse = try await http2.send(Api.modulesRegular())
        
        self.regular = regularResponse.value
        self.accountInfo = infoResponse.value
        self.practices = practicesResponse.value
        
        self.http = http2
        self.account = auth.value        
    }
    
    /// Подключиться `попробовать` без аккаунта
    public func setTrial() async throws {
        let http = HttpClient5(baseURL: Api.baseURL, sessionConfiguration: .withCache)
        
        let trialResponse = try await http.send(Api.modulesTrial())
        self.trial = trialResponse.value
        
        self.http = http
        isTrial = true
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
}
