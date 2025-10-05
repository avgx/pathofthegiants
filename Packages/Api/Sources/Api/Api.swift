import Foundation
import Get
import Models

/// https://pathofthegiants.ru
public enum Api {
    public static let baseURL: URL = URL(string: "https://pathofthegiants.ru")!
    
    public static func modulesTrial() -> Request<Trial> {
        return Request(path: "/Modules/Trial")
    }
    
    public static func file(name: String) -> Request<Data> {
        return Request(path: "/Files/\(name)")
    }
}
