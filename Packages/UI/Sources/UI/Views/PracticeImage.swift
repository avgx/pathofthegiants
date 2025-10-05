import SwiftUI
import Env
import Models

struct PracticeImage: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let practice: Practice
    @State var image: UIImage?
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
            }
        }
        .clipShape(Circle())
        .task {
            let image = try? await currentAccount.fetchImage(for: practice)
            self.image = image ?? UIImage()
        }
    }
}
