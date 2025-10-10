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
}
