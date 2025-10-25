import SwiftUI

struct ProgressBadge: View {
    /// Процент прогресса от 0 до 1
    @Binding var progress: CGFloat
    
    var body: some View {
        ZStack {
            /// Базовая иконка (серая)
            Image(systemName: "checkmark.seal")
                .foregroundStyle(.gray)
                .opacity(progress < 1 ? 1.0 : 0.0)
            /// Частично заполненная окантовка с круговым прогрессом
            Image(systemName: "seal")
                .mask(
                    ProgressMask(progress: progress)
                )
                .opacity(progress < 1 ? 1.0 : 0.0)
            /// Для 100% и checkmark раскрашиваем
            Image(systemName: "checkmark.seal")
                .opacity(progress < 1 ? 0.0 : 1.0)
                .symbolEffect(.bounce, value: progress >= 1)
        }
    }
}

struct ProgressMask: Shape {
    var progress: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2 - 1
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        /// Начинаем с центра
        path.move(to: center)
        /// Точка на окружности с -90 градусов (верхняя точка)
        path.addLine(to: CGPoint(x: center.x, y: center.y  - radius))
        /// Движемся по часовой стрелке
        let startAngle = Angle(degrees: -90)
        let endAngle = Angle(degrees: -90 + 360 * Double(progress))
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        // Возвращаемся в центр
        path.addLine(to: center)
        
        return path
    }
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
}

#Preview {
    @Previewable @State var progress: CGFloat = 0.0
    VStack(spacing: 30) {
        ProgressMask(progress: progress)
            .frame(width: 60, height: 60)
            .foregroundStyle(.red)
        
        ProgressBadge(progress: $progress)
            .font(.largeTitle)
            .foregroundStyle(.blue)
        
        ProgressBadge(progress: $progress)
            .font(.system(size: 60))
            .foregroundStyle(.green)
        
        ProgressBadge(progress: $progress)
            .font(.body)
            .foregroundStyle(.orange)
        
        Slider(value: $progress, in: 0...1)
            .padding()
    }
    .padding()
    .onAppear {
        // Пример прогресса
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            progress = 0.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            progress = 0.7
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            progress = 1.0
        }
    }
}
