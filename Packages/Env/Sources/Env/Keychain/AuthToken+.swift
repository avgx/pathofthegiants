import Foundation
import KeychainSwift
import Models

public extension AuthToken {
    private static var keychain: KeychainSwift {
        let keychain = KeychainSwift()
        return keychain
    }
    
    private static let key: String = "AuthToken"
    
    func save() {
        Self.keychain.set(self, forKey: Self.key, withAccess: .accessibleAfterFirstUnlock)
    }
    
    static func delete() {
        Self.keychain.delete(Self.key)
    }
    
    static func load() -> AuthToken? {
        return Self.keychain.get(key)
    }
}
