import SwiftUI

extension View {
    /// В целом это бажный подход
    /// Если что-то "переключается" на ходу, то будет теряться State
    /// Но для случая когда это "долговременно", т.е. к примеру доп. вью в зависимости от настроек, то норм.
    @ViewBuilder
    public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
