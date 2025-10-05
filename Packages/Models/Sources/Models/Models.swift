import Foundation

public struct Auth: Codable, Sendable {
    public let data: AuthData

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

public struct AuthData: Codable, Sendable {
    public let userID, token: String

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
}

public struct Trial: Codable, Sendable {
    public let data: TrialData

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

public struct TrialData: Codable, Identifiable, Sendable {
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
