import SwiftUI
import Models

/// Подсчет прогресса
/// Накапливает прогресс текущей сессии
/// Хранит прогресс по прослушанному
@MainActor
public class SessionTracker: ObservableObject, Loggable {
    /// Кэш програсса
    @Published public private(set) var progress: [PracticeID : TimeInterval] = [:]
    /// Текущая сессия
    @Published public private(set) var current: Practice?
    /// Общее время текущей сессии
    @Published public private(set) var currentTotal: TimeInterval = 0.0
    /// Время на плеере в текущей сессии
    @Published public private(set) var currentTime: TimeInterval = 0.0
    
    /// Хранилище прогресса
    private let storage = Storage()
    
    init() {
        /// Загружаем сохраненный прогресс при инициализации
        progress = storage.progress
    }
    
    /// computed binding для SwiftUI
    public var currentPracticeBinding: Binding<Practice?> {
        Binding(
            get: { self.current },
            set: { newValue in
                if let practice = newValue {
                    self.start(practice: practice)
                } else {
                    self.cancel()
                }
            }
        )
    }
    
    /// Начать сессию по практике c ID `practice`
    public func start(practice: Practice) {
        current = practice
        /// подгружаем текущий прогресс
        currentTime = progress[current!.id] ?? 0.0
    }
    
    /// Добавить время в текущую сессию
    func add(time: TimeInterval) {
        precondition(current != nil)
        currentTotal += time
    }
    
    /// Сохранить время на плеере
    func set(time: TimeInterval) {
        precondition(current != nil)
        currentTime = time
    }
    
    func setComplete() {
        precondition(current != nil)
        currentTotal = TimeInterval(current!.audioDuration)
        currentTime = TimeInterval(current!.audioDuration)
    }
    
    /// Закрыть сессию, сохранить
    /// `isComplete` показывает завершена или нет
    public func close() {
        precondition(current != nil)
        progress[current!.id] = currentTime
        logger.info("session for \(self.current!.id, privacy: .public) closed: \(self.currentTime, privacy: .public) / \(self.current!.audioDuration, privacy: .public)")
        saveProgress()
        currentTotal = 0.0
        currentTime = 0.0
        current = nil
    }
    
    /// Отменить сессию. Обнулить прогресс и не сохранять.
    public func cancel() {
        currentTotal = 0.0
        currentTime = 0.0
        current = nil
    }
    
    /// Сохранение прогресса
    private func saveProgress() {
        storage.progress = progress
        logger.info("progress: \(self.progress, privacy: .public)")
    }
}


extension SessionTracker {
    /// Пока данных очень мало
    /// + это временное решение до появления серверной поддержки сохранения прогресса
    struct Storage {
        @AppStorage("sessionTracker.progress") var progress: [PracticeID : TimeInterval] = [:]
    }
}

// MARK: - RawRepresentable для словаря прогресса
extension Dictionary: @retroactive RawRepresentable where Key == PracticeID, Value == TimeInterval {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([PracticeID: TimeInterval].self, from: data) else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}
