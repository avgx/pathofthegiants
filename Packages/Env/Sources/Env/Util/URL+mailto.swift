import Foundation

import Foundation

extension URL {
    /// Создаёт URL для mailto‑ссылки с заданными параметрами.
    ///
    /// - Parameters:
    ///   - to: Адрес получателя (обязательный).
    ///   - cc: Адреса для копии (CC).
    ///   - bcc: Адреса для скрытой копии (BCC).
    ///   - subject: Тема письма.
    ///   - body: Текст письма (переносы строк автоматически кодируются как %0D%0A).
    /// - Returns: Готовый URL для mailto‑ссылки или `nil`, если сборка не удалась.
    public static func mailto(
        to: String,
        cc: String? = nil,
        bcc: String? = nil,
        subject: String? = nil,
        body: String? = nil
    ) -> URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = to
        
        var queryItems = [URLQueryItem]()
        
        if let cc = cc {
            queryItems.append(URLQueryItem(name: "cc", value: cc))
        }
        
        if let bcc = bcc {
            queryItems.append(URLQueryItem(name: "bcc", value: bcc))
        }
        
        if let subject = subject {
            queryItems.append(URLQueryItem(name: "subject", value: subject))
        }
        
        if let body = body {
            // Заменяем \n на %0D%0A (CRLF в URL‑кодировке)
            let encodedBody = body.replacingOccurrences(of: "\n", with: "%0D%0A")
            queryItems.append(URLQueryItem(name: "body", value: encodedBody))
        }
        
        components.queryItems = queryItems
        
        return components.url
    }
}

//// Пример 1: Простое письмо
//if let url = URL.mailto(to: "example@example.com") {
//    print(url)  // mailto:example@example.com
//}
//
//// Пример 2: С темой и телом
//if let url = URL.mailto(
//    to: "user@example.com",
//    subject: "Встреча завтра",
//    body: "Привет!\nНапоминаю о встрече в 15:00."
//) {
//    print(url)
//    // mailto:user@example.com?subject=Встреча завтра&body=Привет!%0D%0AНапоминаю о встрече в 15:00.
//}
