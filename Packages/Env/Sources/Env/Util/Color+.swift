import SwiftUI
import UIKit

extension Color {
    /// Создаёт Color из HEX‑строки (с # или без, строго 6 символов).
    init?(hex: String) {
        var hex = hex
        
        // Удаляем #, если есть
        if hex.hasPrefix("#") {
            hex = String(hex.dropFirst())
        }
        
        // Проверяем длину: ровно 6 символов
        guard hex.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        
        guard Scanner(string: hex).scanHexInt64(&rgbValue) else { return nil }
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, opacity: 1.0)
    }
    
    /// Вычисляемое свойство: преобразует Color в HEX‑строку с # (всегда 7 символов: #RRGGBB).
    var hexValue: String {
        // Конвертируем SwiftUI Color в UIColor
        let uiColor = UIColor(self)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Получаем компоненты цвета в sRGB цветовом пространстве
        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return "#FFFFFF" // Возвращаем белый цвет по умолчанию
        }
        
        // Конвертируем в HEX
        let r = Int((red * 255).rounded())
        let g = Int((green * 255).rounded())
        let b = Int((blue * 255).rounded())
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// Поддержка RawRepresentable
extension Color: @retroactive RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        self.init(hex: rawValue)
    }
    
    public var rawValue: String {
        return self.hexValue
    }
}
