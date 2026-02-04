import Foundation
import os.log
///Было import Logging

/// Протокол для объектов, поддерживающих логирование
public protocol Loggable {
    static var logger: Logger { get }
}

public extension Loggable {
    /// Статический логгер для типа
    static var logger: Logger {
        Logger(subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: String(describing: self))
        ///Было Logger(label: String(describing: self).lowercased())
    }
    
    /// Экземплярный логгер (делегирует статическому)
    var logger: Logger {
        Self.logger
    }
}
