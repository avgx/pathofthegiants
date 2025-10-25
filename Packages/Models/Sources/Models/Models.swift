import Foundation

// Локализация ошибок
struct LocalizedError {
    static let requireConfirmedEmail = "Подтвердите регистрацию в письме, которое мы отправили на ваш e-mail"
    static let unauthorized = "Указанный e-mail не зарегистрирован"
    static let invalidParams = "Неверный формат параметров"
    static let invalidPassword = "Неверный e-mail или пароль"
    static let duplicateEmail = "Такой e-mail уже есть в системе"
    static let rateLimit = "Превышен лимит действий. Попробуйте позже"
    static let socket = "Отсутствует подключение к интернету"
    static let unknown = "Неизвестная ошибка. Обратитесь в техподдержку"
}

// Enum для кодов ошибок
public enum ErrorCode: String, Codable {
    case requireConfirmedEmail = "RequireConfirmedEmailClientException"
    case unauthorized = "UnauthorizedClientException"
    case invalidParams = "InvalidParamsClientException"
    case invalidPassword = "InvalidPasswordClientException"
    case duplicateEmail = "DuplicateEmail"
    case rateLimit = "RateLimitClientException"
    case socket = "SocketException"
    case unknown = "UnknownError"
    
    // Метод для получения локализованного сообщения
    public var localizedMessage: String {
        switch self {
        case .requireConfirmedEmail:
            return LocalizedError.requireConfirmedEmail
        case .unauthorized:
            return LocalizedError.unauthorized
        case .invalidParams:
            return LocalizedError.invalidParams
        case .invalidPassword:
            return LocalizedError.invalidPassword
        case .duplicateEmail:
            return LocalizedError.duplicateEmail
        case .rateLimit:
            return LocalizedError.rateLimit
        case .socket:
            return LocalizedError.socket
        case .unknown:
            return LocalizedError.unknown
        }
    }
}

// Структура для ответа об ошибке
public struct ErrorResponse: Codable {
    public let error: ErrorDetails
    
    enum CodingKeys: String, CodingKey {
        case error = "Error"
    }
    
    public struct ErrorDetails: Codable {
        public let code: ErrorCode
        
        enum CodingKeys: String, CodingKey {
            case code = "Code"
        }
        
        // Вычисляемое свойство для получения локализованного сообщения
        public var message: String {
            code.localizedMessage
        }
    }
}

public struct Auth: Codable, Sendable {
    public let data: AuthData

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

public typealias AuthToken = String

public struct AuthData: Codable, Sendable {
    public let userID: String
    public let token: AuthToken

    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case token = "Token"
    }
}

public struct AccountInfo: Codable, Sendable {
    public let data: AccountInfoData

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
    
    public init(data: AccountInfoData) {
        self.data = data
    }
}

public struct AccountInfoData: Codable, Sendable {
    public let userID, email, nickname: String
    public let subscriptionLevel: Int
    public let avatar: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case email = "Email"
        case nickname = "Nickname"
        case avatar = "Avatar"
        case subscriptionLevel = "SubscriptionLevel"
    }
    
    public init(userID: String, email: String, nickname: String, subscriptionLevel: Int, avatar: String? = nil) {
        self.userID = userID
        self.email = email
        self.nickname = nickname
        self.avatar = avatar
        self.subscriptionLevel = subscriptionLevel
    }
}

public struct UserStats: Codable, Sendable {
    public let data: UserStatsData

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

public struct UserStatsData: Codable, Sendable {
    public let totalPractices, totalPracticeTime, maximumConsecutiveDaysForPractices: Int
    public let favoritePractice: FavoritePractice?
    
    enum CodingKeys: String, CodingKey {
        case totalPractices = "TotalPractices"
        case totalPracticeTime = "TotalPracticeTime"
        case maximumConsecutiveDaysForPractices = "MaximumConsecutiveDaysForPractices"
        case favoritePractice = "FavoritePractice"
    }
}

public struct FavoritePractice: Codable, Sendable {
    public let practiceID, listeningCount: Int

    enum CodingKeys: String, CodingKey {
        case practiceID = "PracticeId"
        case listeningCount = "ListeningCount"
    }
}


public struct Practices: Codable, Sendable {
    public let data: [Practice]

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

public struct Regular: Codable, Sendable {
    public let data: [ModuleData]

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

public struct Trial: Codable, Sendable {
    public let data: ModuleData

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

public typealias ModuleID = Int

public struct ModuleData: Codable, Identifiable, Sendable {
    public let id: ModuleID
    public let name, description, image: String
    public let opened, trial: Bool
    public let orderNumber: Int
    public let practicesIDS: [Int]
    public let practices: [Practice]
    public let isPaid: Bool
    public let whenCreated: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case description = "Description"
        case image = "Image"
        case opened = "Opened"
        case trial = "Trial"
        case orderNumber = "OrderNumber"
        case practicesIDS = "PracticesIds"
        case practices = "Practices"
        case isPaid = "IsPaid"
        case whenCreated = "WhenCreated"
    }
}

extension ModuleData: Hashable {
    public static func == (lhs: ModuleData, rhs: ModuleData) -> Bool {
        return lhs.id == rhs.id
    }
}

public typealias PracticeID = Int
extension PracticeID {
    public static let invalid = -1
}

public struct Practice: Codable, Identifiable, Sendable {
    public let id: PracticeID
    public let name, briefDescription, description, image: String
    public let audio: String
    public let audioDuration: Int
    public let group: PracticeGroup
    public let pose: String
    public let complication, subscriptionLevel: Int
    public let whenCreated: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case briefDescription = "BriefDescription"
        case description = "Description"
        case image = "Image"
        case audio = "Audio"
        case audioDuration = "AudioDuration"
        case group = "Group"
        case pose = "Pose"
        case complication = "Complication"
        case subscriptionLevel = "SubscriptionLevel"
        case whenCreated = "WhenCreated"
    }
}

extension Practice {
    public typealias PracticeGroup = String
}

extension Practice: Hashable {
    public static func == (lhs: Practice, rhs: Practice) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Practice.PracticeGroup {
    public var groupOrder: Int {
        Practice.Group.order(for: self)
    }
}

extension Practice {
    public enum Group : String, Codable, CaseIterable, Identifiable, Sendable {
        case visualization = "Визуализация"
        case sensations = "Ощущения"
        case breathingExercises = "Дыхательное упражнение"
        case backgroundMusic = "Фоновая музыка"
        case objectMeditation = "Медитация на предмете"
        case goals = "Цели"
        case thoughtObservation = "Наблюдение за мыслями"
        case gratitude = "Благодарность"
        case stories = "Истории"
        
        public var id: String { self.rawValue }
        
        /// Порядковый номер для сортировки
        public var order: Int {
            return Self.allCases.firstIndex(of: self) ?? Self.allCases.count
        }
        
        /// Получить порядковый номер для строки (если строка не соответствует enum, возвращает максимальное значение)
        public static func order(for groupString: String) -> Int {
            return Self.allCases.map({ $0.rawValue }).firstIndex(of: groupString) ?? Self.allCases.count
        }
    }
}
