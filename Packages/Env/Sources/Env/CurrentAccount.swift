import SwiftUI
import Models
import Api
import Get

@MainActor
public class CurrentAccount: ObservableObject {
    
    @Published public private(set) var isTrial: Bool = false
    @Published public private(set) var token: AuthToken?
    @Published public private(set) var accountInfo: AccountInfo?
    @Published public private(set) var avatarImage: UIImage?
    @Published public private(set) var practices: Practices?
    @Published public private(set) var trial: Trial?
    @Published public private(set) var regular: Regular?
    private var currentPractice: Practice? {
        tracker.current
    }
    public private(set) var tracker: SessionTracker = SessionTracker()
    
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
        guard let jwt = JwtToken(jwtString: auth.value.data.token) else {
            throw AppError.tokenNotFound
        }
        print(jwt.detailedInfo())
        auth.value.data.token.save()
    }
    
    public func connect() async throws {
        guard let token = AuthToken.load() else {
            throw AppError.tokenNotFound
        }
        
        guard let jwt = JwtToken(jwtString: token) else {
            throw AppError.tokenNotFound
        }
        print(jwt.detailedInfo())
        
        let http2 = HttpClient5(baseURL: Api.baseURL, authorization: .bearer(token), sessionConfiguration: .withCache)
        let infoResponse = try await http2.send(Api.accountInfo())
        let practicesResponse = try await http2.send(Api.practices())
        let regularResponse = try await http2.send(Api.modulesRegular())
        
        self.regular = regularResponse.value
        self.accountInfo = infoResponse.value
        self.practices = practicesResponse.value
        
        self.http = http2
        self.token = token
        
        if let avatarFile = infoResponse.value.data.avatar {
            self.avatarImage = try? await fetchAvatar(for: avatarFile)
        }
    }
    
    /// Подключиться `попробовать` без аккаунта
    public func setTrial() async throws {
        let http = HttpClient5(baseURL: Api.baseURL, sessionConfiguration: .withCache)
        
        let trialResponse = try await http.send(Api.modulesTrial())
        self.trial = trialResponse.value
        
        self.http = http
        isTrial = true
    }
    
    /// Зарегистрировать аккаунт
    public func signup(user: String, pass: String) async throws {
        let http = HttpClient5(baseURL: Api.baseURL, sessionConfiguration: .withCache)

        _ = try await http.send(Api.accountSignup(user: user, password: pass))
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
    
    public func fetchAvatar(for image: String) async throws -> UIImage {
        guard let http else { return UIImage() }
        
        let imageData = try await http.send(Api.fileForceReload(name: image))
        let image = UIImage(data: imageData.data) ?? UIImage()
        return image
    }
    
    
    public func clearCached(image: String) async throws {
        guard let http else { return }
        
        let req = try await http.makeURLRequest(for: Api.file(name: image))
        URLCache.imageCache.removeCachedResponse(for: req)
    }
    
    public func fetchAudio(for practice: Practice) async throws -> Data? {
        guard let http else { return nil }
        
        let audioData = try await http.send(Api.file(name: practice.audio))
        return audioData.data
    }
    
    public func fetchAudioUrl(for practice: Practice) async throws -> URL? {
        guard let http else { return nil }
        
        let audioUrl = try await http.makeURLRequest(for: Api.file(name: practice.audio))
        return audioUrl.url
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
    
    public func update(avatar: UIImage) async throws {
        guard let http else { return }
        guard let jpeg = avatar.resize240().jpegData(compressionQuality: 0.9) else { return }
        
        let r = Api.profileAvatar()
        var request = try await http.makeURLRequest(for: r)
        
        var formData = MultipartFormData()
        
        formData.addFile(named: "file", data: jpeg, mimeType: "image/jpeg", forField: "file")
        let body = formData.makeBody()
        request.httpBody = body
        request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        let (data, httpResponse) = try await http.session.dataTask(for: request)
        if let image = String(data:data, encoding: .ascii) {
            try? await clearCached(image: image)
            self.avatarImage = try? await fetchAvatar(for: image)
        }
        self.accountInfo = try await http.send(Api.accountInfo()).value
    }
}

extension UIImage {
    public func resize240() -> UIImage {
        let w = 240.0
        let original = self.size
        let targetSize = CGSize(width: w, height: w * original.height/original.width)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

extension CurrentAccount {
    public func startPractice(_ practice: Practice) {
        tracker.start(practice: practice)
    }
    
    public func closePractice() {
        tracker.close()
    }
    
    public func cancelPractice() {
        tracker.cancel()
    }
}

extension CurrentAccount: AudioPlayerDelegate {
    public func audioPlayerListenedTime(duration: TimeInterval, currentTime: TimeInterval) {
        print("CurrentAccount audioPlayerListenedTime \(duration), currentTime:\(currentTime)")
        guard let http else { return }
        guard let currentPractice else { return }
        
        tracker.set(time: currentTime)
        tracker.add(time: duration)
        
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
            
            try? await saveHealthKitSession(duration: duration)
        }
    }
    
    public func audioPlayerDidFinishPlaying(duration: TimeInterval) {
        print("CurrentAccount audioPlayerDidFinishPlaying \(duration)")
        
        guard let http else { return }
        guard let currentPractice else { return }
        
        Task {
            _ = try? await http.send(Api.postCompleted(practiceId: currentPractice.id, seconds: duration))
            tracker.setComplete()
        }
    }
    
    
}

extension CurrentAccount {
    public func saveHealthKitSession(duration: TimeInterval) async throws {
        
        guard SettingsManager.shared.appleHealthEnabled else { return }
        
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-duration)
        // Сохранение сессии
        do {
            let success = try await HealthKitManager.shared.saveMindfulSession(
                startDate: startDate,
                endDate: endDate
            )
            if success {
                print("Сессия успешно сохранена")
            }
        } catch {
            print("Ошибка сохранения: \(error.localizedDescription)")
        }
    }
}
