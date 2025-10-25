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
        .task {
            let image = try? await currentAccount.fetchImage(for: practice.image)
            self.image = image ?? UIImage()
        }
    }
}
