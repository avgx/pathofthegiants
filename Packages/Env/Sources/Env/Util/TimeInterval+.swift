import Foundation

extension TimeInterval {
    public func formatTime() -> String {
        let time = self
        let sign = time < 0 ? "-" : ""
        let minutes = Int(abs(time)) / 60
        let seconds = Int(abs(time)) % 60
        return String(format: "\(sign)%d:%02d", minutes, seconds)
    }
}
