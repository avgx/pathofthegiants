import SwiftUI
import Env

@MainActor
var bgMain: UIImage?

struct MainBackground: View {
    @EnvironmentObject var currentAccount: CurrentAccount
    
    @State var image: UIImage?
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                
//                Image("bgMain")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .ignoresSafeArea()
            }
        }
        .onAppear {
            if let bgMain {
                self.image = bgMain
            }
        }
        .task {
            guard image == nil else { return }
            
            let image = try? await currentAccount.fetchBgMain()
            self.image = image ?? UIImage()
            bgMain = image            
        }
        
        
    }
}
