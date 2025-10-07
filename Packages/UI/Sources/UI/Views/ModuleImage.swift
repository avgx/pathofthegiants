import SwiftUI
import Env
import Models

struct ModuleImage: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    let module: ModuleData
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
            let image = try? await currentAccount.fetchImage(for: module.image)
            self.image = image ?? UIImage()
        }
    }
}
