import Foundation
import Get
import Models

/// https://pathofthegiants.ru
public enum Api {
    public static let baseURL: URL = URL(string: "https://pathofthegiants.ru")!
    
    
    public static func accountLogin(user: String, password: String) -> Request<Auth> {
        return Request(path: "/Account/Login/", method: .post, query: [
            ("login", user),
            ("password", password)
        ])
    }
    
    public static func accountInfo() -> Request<AccountInfo> {
        //force no cache
        return Request(path: "/Account/Info", query: [("_", "\(Date().timeIntervalSinceReferenceDate)")])
    }
    
    public static func profile(nickname: String) -> Request<Void> {
        return Request(path: "/Profile/Nickname", method: .post, query: [("nickname", nickname)])
    }
    
    public static func modulesRegular() -> Request<Regular> {
        return Request(path: "/Modules/Regular")
    }
    
    public static func modulesTrial() -> Request<Trial> {
        return Request(path: "/Modules/Trial")
    }
    
    public static func practices() -> Request<Practices> {
        return Request(path: "/Practices")
    }
    
    public static func stats() -> Request<UserStats> {
        //force no cache
        return Request(path: "/UserStats", query: [("_", "\(Date().timeIntervalSinceReferenceDate)")])
    }
    
    enum UserActivityType: Int, Codable {
        case PracticeListening = 1
        case PracticeListeningCompleted = 2
    }
    
    struct AdduserStatRequest: Codable {
        let ActivityType: UserActivityType
        let ActivityId: String
        let Value: Double
    }
    
    public static func postProgress(practiceId: Int, seconds: Double) -> Request<Void> {
        return Request(
            path: "/UserStats",
            method: .post,
            body: AdduserStatRequest(
                ActivityType: .PracticeListening,
                ActivityId: "\(practiceId)",
                Value: seconds,
            )
        )
    }
    public static func postCompleted(practiceId: Int, seconds: Double) -> Request<Void> {
        return Request(
            path: "/UserStats",
            method: .post,
            body: AdduserStatRequest(
                ActivityType: .PracticeListeningCompleted,
                ActivityId: "\(practiceId)",
                Value: seconds,
            )
        )
    }
    
    public static func file(name: String) -> Request<Data> {
        return Request(path: "/Files/\(name)")
    }
}
