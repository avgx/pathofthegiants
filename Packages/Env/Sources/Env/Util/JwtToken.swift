import Foundation

struct JwtToken {
    let payload: [String: Any]
    let issuedAt: Date?
    let expiration: Date?
    
    init?(jwtString: String) {
        let segments = jwtString.components(separatedBy: ".")
        guard segments.count == 3 else { return nil }
        
        // Декодируем только payload (вторая часть)
        guard let payloadData = JwtToken.base64UrlDecode(segments[1]),
              let payload = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any] else {
            return nil
        }
        
        self.payload = payload
        
        // Извлекаем временные метки
        self.issuedAt = JwtToken.extractDate(from: payload, key: "iat")
        self.expiration = JwtToken.extractDate(from: payload, key: "exp")
    }
    
    // Проверяем валидность токена по времени
    var isValid: Bool {
        guard let expiration = expiration else { return true }
        return Date() < expiration
    }
    
    // Время до истечения в секундах
    var timeUntilExpiration: TimeInterval? {
        guard let expiration = expiration else { return nil }
        return expiration.timeIntervalSince(Date())
    }
    
    // Время с момента создания в секундах
    var timeSinceIssued: TimeInterval? {
        guard let issuedAt = issuedAt else { return nil }
        return Date().timeIntervalSince(issuedAt)
    }
    
    private static func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Добавляем padding если необходимо
        let padding = base64.count % 4
        if padding > 0 {
            base64 += String(repeating: "=", count: 4 - padding)
        }
        
        return Data(base64Encoded: base64)
    }
    
    private static func extractDate(from payload: [String: Any], key: String) -> Date? {
        guard let timestamp = payload[key] as? TimeInterval else { return nil }
        return Date(timeIntervalSince1970: timestamp)
    }
}

// Пример использования
func parseJWTToken(_ jwtString: String) {
    guard let token = JwtToken(jwtString: jwtString) else {
        print("Неверный формат JWT токена")
        return
    }
    
    print("=== JWT Token Information ===")
    
    if let issuedAt = token.issuedAt {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        print("Создан: \(formatter.string(from: issuedAt))")
    } else {
        print("Время создания не указано")
    }
    
    if let expiration = token.expiration {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        print("Истекает: \(formatter.string(from: expiration))")
        
        if token.isValid {
            print("Токен валиден")
            if let timeLeft = token.timeUntilExpiration {
                print("Осталось времени: \(Int(timeLeft)) секунд")
            }
        } else {
            print("Токен просрочен")
        }
    } else {
        print("Время истечения не указано")
    }
    
    if let timeSinceIssued = token.timeSinceIssued {
        print("Прошло с момента создания: \(Int(timeSinceIssued)) секунд")
    }
}

// Альтернативная версия с более детальной информацией
extension JwtToken {
    func detailedInfo() -> String {
        var info = "JWT Token Details:\n"
        
        if let issuedAt = issuedAt {
            info += "• Создан: \(issuedAt)\n"
            info += "• Прошло времени: \(formatTimeInterval(timeSinceIssued ?? 0))\n"
        }
        
        if let expiration = expiration {
            info += "• Истекает: \(expiration)\n"
            info += "• Валиден: \(isValid ? "Да" : "Нет")\n"
            if isValid, let timeLeft = timeUntilExpiration {
                info += "• Осталось: \(formatTimeInterval(timeLeft))\n"
            }
        }
        
        return info
    }
    
    func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 2 // Ограничиваем количество единиц
        
        return formatter.string(from: interval) ?? "0 секунд"
    }
}
//
//// Пример с реальным JWT токеном
//let exampleJWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
//
//// Использование
//parseJWTToken(exampleJWT)
//
//// Или с использованием структуры
//if let token = JWTToken(jwtString: exampleJWT) {
//    print(token.detailedInfo())
//    
//    // Проверка валидности
//    if token.isValid {
//        print("Токен можно использовать")
//    } else {
//        print("Токен просрочен, требуется обновление")
//    }
//    
//    // Доступ к другим полям payload если нужно
//    if let subject = token.payload["sub"] as? String {
//        print("Subject: \(subject)")
//    }
//}
