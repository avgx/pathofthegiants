import Foundation

extension URLSessionConfiguration {
    public class var withCache: URLSessionConfiguration {
        let x: URLSessionConfiguration = .default
        x.timeoutIntervalForRequest = 10
        x.timeoutIntervalForResource = 30
        x.requestCachePolicy = .returnCacheDataElseLoad
        x.urlCache = .imageCache
        return x
    }
}
