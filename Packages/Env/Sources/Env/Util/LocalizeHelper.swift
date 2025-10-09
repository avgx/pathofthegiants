import Foundation

public enum LocalizeHelper {
    /// Склонение слова «день» зависит от числа.
    /// Вот правильные варианты для разных чисел:
    ///    1 день подряд
    ///    2, 3, 4 дня подряд
    ///    5, 6, 7, 8, 9, 10 дней подряд
    ///    11, 12, 13, …, 19 дней подряд (всегда “дней”)
    ///    21 день подряд
    ///    22, 23, 24 дня подряд
    ///    25, 26, …, 30 дней подряд
    ///    31 день подряд
    public static func localizedDaysString(_ days: Int) -> String {
        let number = days % 100
        let lastDigit = days % 10
        
        switch (number, lastDigit) {
        case (11...14, _):
            return "дней подряд"
        case (_, 1):
            return "день подряд"
        case (_, 2...4):
            return "дня подряд"
        default:
            return "дней подряд"
        }
    }

    ///Правило склонения
    ///    1 минута
    ///    2, 3, 4 минуты
    ///    5, 6, 7, 8, 9, 10 минут
    ///    11, 12, 13,…, 19 минут (всегда “минут”)
    ///    21 минута
    ///    22, 23, 24 минуты
    ///    25, 26,…, 30 минут
    ///    31 минута
    public static func localizedMinutesString(_ minutes: Int) -> String {
        let number = minutes % 100
        let lastDigit = minutes % 10
        
        switch (number, lastDigit) {
        case (11...14, _):
            return "минут"
        case (_, 1):
            return "минута"
        case (_, 2...4):
            return "минуты"
        default:
            return "минут"
        }
    }

    ///Правило склонения
    ///    1 практика
    ///    2, 3, 4 практики
    ///    5, 6, 7, 8, 9, 10 практик
    ///    11, 12, 13,…, 19 практик (всегда “практик”)
    ///    21 практика
    ///    22, 23, 24 практики
    ///    25, 26,…, 30 практик
    ///    31 практика
    public static func localizedPracticesString(_ practices: Int) -> String {
        let number = practices % 100
        let lastDigit = practices % 10
        
        switch (number, lastDigit) {
        case (11...14, _):
            return "практик"
        case (_, 1):
            return "практика"
        case (_, 2...4):
            return "практики"
        default:
            return "практик"
        }
    }

}
