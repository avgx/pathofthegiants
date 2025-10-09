import Foundation

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
    
    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case email = "Email"
        case nickname = "Nickname"
        case subscriptionLevel = "SubscriptionLevel"
    }
    
    public init(userID: String, email: String, nickname: String, subscriptionLevel: Int) {
        self.userID = userID
        self.email = email
        self.nickname = nickname
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
    public let favoritePractice: FavoritePractice
    
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

public struct ModuleData: Codable, Identifiable, Sendable {
    public let id: Int
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

public struct Practice: Codable, Identifiable, Sendable {
    public let id: Int
    public let name, briefDescription, description, image: String
    public let audio: String
    public let audioDuration: Int
    public let group, pose: String
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

extension Practice: Hashable {
    public static func == (lhs: Practice, rhs: Practice) -> Bool {
        return lhs.id == rhs.id
    }
}
