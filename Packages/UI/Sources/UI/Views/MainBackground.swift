import SwiftUI

struct MainBackground: View {
    var body: some View {
        Image("bgMain")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}
