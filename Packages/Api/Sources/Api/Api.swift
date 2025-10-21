import Foundation
import Get
import Models

/// https://pathofthegiants.ru
public enum Api {
    public static let baseURL: URL = URL(string: "https://pathofthegiants.ru")!
    
    //TODO: обработать ошибки
    /// 404 Not Found
    /// 403
    /// {"Error":{"Code":"RequireConfirmedEmailClientException"}}
    /// 400
    /// {"Error":{"Code":"InvalidPasswordClientException"}}
    public static func accountLogin(user: String, password: String) -> Request<Auth> {
        return Request(path: "/Account/Login/", method: .post, query: [
            ("login", user),
            ("password", password)
        ])
    }
    
    //TODO: обработать ошибки
    /// {"Error":{"Code":"InvalidParamsClientException","Data":{"Field":["email"]}}}
    /// {"Error":{"Code":"InvalidParamsClientException","Data":{"Field":["password"]}}}
    /// {"Error":{"Code":"DuplicateEmail","Data":{"Description":"Email 'aaa@gmail.com' is already taken."}}}
    public static func accountSignup(user: String, password: String) -> Request<String> {
        return Request(path: "/Account/Signup/", method: .post, query: [
            ("login", user),
            ("password", password)
        ])
    }
    
    //TODO: POST /Account/SendEmailConfirmation?login=aa%40aa.aa&password=zzz
    //{"Error":{"Code":"NotFoundClientException"}}
    
    /// Подтверждение email
    public static func confirmEmail(user: String, token: String) -> Request<String> {
        return Request(path: "/Account/ConfirmEmail", method: .get, query: [
            ("email", user),
            ("token", token)
        ])
    }
    
    public static func accountInfo() -> Request<AccountInfo> {
        //force no cache
        return Request(path: "/Account/Info", query: [("_", "\(Date().timeIntervalSinceReferenceDate)")])
    }
    
    public static func profile(nickname: String) -> Request<Void> {
        return Request(path: "/Profile/Nickname", method: .post, query: [("nickname", nickname)])
    }
    
    //TODO: POST /Profile/Avatar
//    curl -X 'POST' \
//      'https://pathofthegiants.ru/Profile/Avatar' \
//      -H 'accept: text/plain' \
//      -H 'Content-Type: multipart/form-data' \
//      -F 'file=@Simulator.png;type=image/png'
    public static func profileAvatar() -> Request<Void> {
        return Request(path: "/Profile/Avatar", method: .post)
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
    
    public static func file(name: String, forceNetwork: Bool = false) -> Request<Data> {
        return Request(path: "/Files/\(name)", query: forceNetwork ? [("_", "\(Date().timeIntervalSinceReferenceDate)")] : nil)
    }
    
    public static func bgMain() -> Request<Data> {
        return Request(path: "/bgMain.png")
    }
    public static func bgSecond() -> Request<Data> {
        return Request(path: "/bgSecond.png")
    }
}
