import Foundation
import OSLog
import os.log

/// https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code
/// 
//public extension Loggable {
//    public static func export() -> [Data] {
//        do {
//            let store = try OSLogStore(scope: .currentProcessIdentifier)
//            let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
//            let position = store.position(date: threeDaysAgo)
//
//            let entries = try store.getEntries(at: position)
//                .compactMap { $0 as? OSLogEntryLog }
//                .filter { $0.subsystem == "com.msg.onmir" }
//
//            let datas = entries.compactMap { logEntry -> Data? in
//                let formattedLog = """
//          \(logEntry.date) \(logEntry.category) \
//          [\(logEntry.subsystem)] \
//          \(logEntry.composedMessage)\n
//          """
//
//                return formattedLog.data(using: .utf8)
//            }
//            return datas
//        } catch {
//            print("Failed to retrieve logs: \(error)")
//            return []
//        }
//    }
//}

public enum LoggerExport {
    static func export2() -> [String] {
            do {
                let store = try OSLogStore(scope: .currentProcessIdentifier)
                let position = store.position(timeIntervalSinceLatestBoot: 1)
                let logs = try store
                    .getEntries(at: position)
                    .compactMap { $0 as? OSLogEntryLog }
//                    .filter { $0.subsystem == Self.loggingSubsystem }
                    .map { "[\($0.date.formatted())] [\($0.category)] \($0.composedMessage)" }
                return logs
            } catch {
                return []
            }
        }
    
        public static func export(subsystem: String = Bundle.main.bundleIdentifier ?? "unknown") -> [String] {
            do {
                let store = try OSLogStore(scope: .currentProcessIdentifier)
                let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
                let position = store.position(date: threeDaysAgo)
    
                let entries = try store.getEntries(at: position)
                    .compactMap { $0 as? OSLogEntryLog }
                    .filter { $0.subsystem == subsystem }
    
                let datas = entries.compactMap { logEntry -> String? in
                    let formattedLog = """
              \(logEntry.date) \(logEntry.category) \
              [\(logEntry.subsystem)] \
              \(logEntry.composedMessage)\n
              """
    
                    return formattedLog //.data(using: .utf8)
                }
                return datas
            } catch {
                print("Failed to retrieve logs: \(error)")
                return []
            }
        }
    
    public static func exportEntries(subsystem: String = Bundle.main.bundleIdentifier ?? "unknown", category: String? = nil, date: Date? = nil)
    -> [String]
    {
        var entries: [String] = []
        
        do {
            let store: OSLogStore
            var position: OSLogPosition
            
                // entries from just the current process
                store = try OSLogStore(scope: .currentProcessIdentifier)
                position = store.position(timeIntervalSinceLatestBoot: 1)
            
            
            // command line help for predicates
            // log help predicates
            var predicate: NSPredicate
            if let category = category {
                let subsystemPredicate = NSPredicate(format: "(subsystem == %@)", subsystem)
                let categoryPredicate = NSPredicate(format: "(category == %@)", category)
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                    subsystemPredicate, categoryPredicate,
                ])
            } else {
                predicate = NSPredicate(format: "(subsystem == %@)", subsystem)
            }
            
            entries =
            try store
                .getEntries(at: position, matching: predicate)
                .compactMap { $0 as? OSLogEntryLog }
                .map { "[\($0.date.formatted())] [\($0.category)] \($0.composedMessage)" }
        } catch {
            //Logger.error.warning("\(error.localizedDescription, privacy: .public)")
        }
        
        return entries
    }
}

extension DefaultStringInterpolation {
    mutating func appendInterpolation<T: OSLogEntryLog>(_ entry: T) {
        var levelString = ""
        switch entry.level {
        case .error:
            levelString = "error"
        case .undefined:
            levelString = "undefined"
        case .debug:
            levelString = "debug"
        case .info:
            levelString = "info"
        case .notice:
            levelString = "notice"
        case .fault:
            levelString = "fault"
        @unknown default:
            levelString = "unknown"
        }

        let isoDateFormatter = ISO8601DateFormatter()
        //        isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        isoDateFormatter.timeZone = TimeZone.current
        isoDateFormatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withDashSeparatorInDate,
            .withFractionalSeconds,
        ]

        let isoDate = isoDateFormatter.string(from: entry.date)

        // compact   Compact human readable output.  ISO-8601 date (millisecond precision),
        // abbreviated log type, process, processID, thread ID, subsystem, category and
        // message content.

        // let category = entry.category.padding(toLength: 13, withPad: " ", startingAt: 0)

        let subsyscat = "\(entry.subsystem):\(entry.category)".padding(
            toLength: 42, withPad: " ", startingAt: 0)

        var s = ""
        //        s += "[\(entry.date.formatted())] "
        //        s += "[\(entry.date.ISO8601Format())]) "
        s += "[\(isoDate)] "
        // log type?
        s += "\(entry.process)[\(entry.processIdentifier):\(entry.threadIdentifier)] "
        s += "[\(levelString)] "  // not in compact
        //        s += "[\(entry.subsystem)] "
        //        s += "[\(category)] "
        s += "[\(subsyscat)] "
        s += "\(entry.composedMessage) "
        appendInterpolation(s)
    }
}

// extension OSLogEntryLog: CustomStringConvertible {
//
//    public override var description: String {
//        var s = ""
//        var levelString = ""
//        switch level {
//        case .error:
//            levelString = "error"
//        case .undefined:
//            levelString = "undefined"
//        case .debug:
//            levelString = "debug"
//        case .info:
//            levelString = "info"
//        case .notice:
//            levelString = "notice"
//        case .fault:
//            levelString = "fault"
//        @unknown default:
//            levelString = "unknown"
//        }
//
//
//        s += "[\(date.formatted())] "
//        s += "[\(category)] "
//        s += "[\(category)] "
//        s += "[\(levelString)] "
//        s += "\(composedMessage) "
//
//        return s
//    }
// }
