import SwiftUI
import Foundation
import os.log

private let lifecycle = Logger(subsystem: Bundle.main.bundleIdentifier ?? "unknown", category: "Lifecycle")

struct LifecycleLogViewModifier: ViewModifier {
    // Имя вью для логирования (передаётся извне или определяется автоматически)
    let viewName: String
    let level: OSLogType
    
    // Таймер для расчёта длительности
    @State private var startTime: Date?
    
    init(viewName: String, level: OSLogType = .info) {
        // Если имя не передано — пытаемся извлечь из типа
        self.viewName = viewName
        self.level = level
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                startTime = Date()
                lifecycle.log(level: level, "[\(viewName, privacy: .public)]")
            }
            .onDisappear {
                guard let start = startTime else { return }
                let duration = Date().timeIntervalSince(start)
                lifecycle.info("[~\(viewName, privacy: .public)]: \(String(format: "%.2f", duration), privacy: .public)")
                startTime = nil
            }
    }
    
    
}

extension View {
    /// Логирует жизненный цикл вью с переданным автоматически определенным именем
    /// Использовать так
    /// `.lifecycleLog(String(reflecting: Self.self))`
    public func lifecycleLog(_ inferredViewName: String) -> some View {
        modifier(LifecycleLogViewModifier(viewName: inferredViewName ))
    }
    
    /// Логирует жизненный цикл с явным указанием имени
    public func lifecycleLog(name: String) -> some View {
        modifier(LifecycleLogViewModifier(viewName: name))
    }
    
}
