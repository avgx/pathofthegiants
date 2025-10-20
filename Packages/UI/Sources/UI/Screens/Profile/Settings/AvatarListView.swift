import SwiftUI
import PhotosUI
import Env
import Models

struct AvatarListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) var isPresented
    
    @Binding var selectedImage: UIImage?
    @Binding var avatarS: String
    
    var body: some View {
        NavigationStack {
            avatarList
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .cancellationAction) {
                    if isPresented {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    var avatarList: some View {
        let width: Double = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2
        let adaptiveHalf = [ GridItem(.adaptive(minimum: width * 0.8, maximum: width * 1.2), spacing: 8) ]
        LazyVGrid(columns: adaptiveHalf) {
            ForEach(["avatar1", "avatar2", "avatar3", "avatar4"], id: \.self) { avatarString in
                Button(action: {
                    selectedImage = nil
                    avatarS = avatarString
                    dismiss()
                }) {
                    Image(avatarString)
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .clipShape(.circle)
                        //.frame(height: 60)
                }
            }
        }
    }
}
