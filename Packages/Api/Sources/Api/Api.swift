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
        return Request(path: "/Account/Info")
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
    
    public static func file(name: String) -> Request<Data> {
        return Request(path: "/Files/\(name)")
    }
}
