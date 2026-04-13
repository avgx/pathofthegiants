import Foundation

extension Bundle {
    public var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    public var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    public var versionBuild: String {
        "\(appVersion) (\(buildNumber))"
    }
    
    public var appStoreId: String {
        infoDictionary?["APPSTORE_ID"] as? String ?? "Unknown"
    }
    
    public var isReaderApp: Bool {
        true
    }
}
