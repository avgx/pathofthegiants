import SwiftUI

extension Profile {
    struct StatisticsView: View {
        
        var body: some View {
            List {
                Section {
                    Text("Подсчет времени практики")
                    
                    Text("каждую секунду")
                    Text("каждую минуту")
                    Text("когда 90% практики пройдено")
                    Text("только практику целиком")
//                    Text("разрешить перемотку")
//                    Text("сохранять прогресс")
                }
            }
        }
    }
}
