import SwiftUI
import PhotosUI
import Env
import Models



extension Profile {
    struct AccountView: View {
        @EnvironmentObject var currentAccount: CurrentAccount
        
        enum Constants {
            static let avatarHeight: CGFloat = 200
        }
        
        @State var nickname = ""
        @State var avatarS = "avatar4"
        
        @State private var selectedItem: PhotosPickerItem?
        @State private var selectedImage: UIImage?
        @State private var showActionSheet = false
        @State private var showPhotosPicker = false
        @State private var showAvatarPicker = false
        
        var body: some View {
            list
                .toolbar(.hidden, for: .tabBar)
                .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItem, matching: .any(of: [.images, .screenshots]), preferredItemEncoding: .compatible)
                .sheet(isPresented: $showAvatarPicker, content: {
                    AvatarListView(selectedImage: $selectedImage, avatarS: $avatarS)
                })
                .confirmationDialog("Выбрать аватар", isPresented: $showActionSheet, titleVisibility: .hidden) {
                    Button("Выбрать аватар") {
                        showAvatarPicker = true
                    }
                    
                    Button("Загрузить из галереи") {
                        showPhotosPicker = true
                    }
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        await loadImage(from: newItem)
                    }
                }
                .onChange(of: selectedImage) { _, newImage in
                    if let newImage = newImage {
                        selectedImage = newImage
                    }
                }
        }
        
        
        @ViewBuilder
        var list: some View {
            List {
                Section {
                    HStack {
                        Spacer()
                        avatar
                            .overlay(alignment: .bottomTrailing, content: {
                                Button(action: { showActionSheet = true }) {
                                    Image(systemName: "pencil")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(16)
                                        .glassEffect()
                                        .clipShape(.circle)
                                        .padding(8)
                                }
                            })
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                
                Section {
                    TextField("Псевдоним", text: $nickname)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                        .keyboardType(.default)
                        .submitLabel(.done)
                        .onSubmit {
                            Task {
                                try? await currentAccount.update(nickname: nickname)
                            }
                        }
                } header: {
                    Text("Псевдоним")
                }
                .onAppear {
                    nickname = currentAccount.accountInfo?.data.nickname ?? ""
                }
                
                exitButton
            }
        }
        
        @ViewBuilder
        var avatar: some View {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(.circle)
                    .frame(height: Constants.avatarHeight)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
            } else {
                Image(avatarS)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipShape(.circle)
                    .frame(height: Constants.avatarHeight)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
            }
        }
        
        @ViewBuilder
        var exitButton: some View {
            Section {
                Button(action: {
                    currentAccount.disconnect()
                }, label: {
                    HStack {
                        Spacer()
                        Text("Выйти из аккаунта")
                        Spacer()
                    }
                    .compositingGroup()
                    .padding(8)
                })
                .buttonStyle(.borderedProminent)
                
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
        }
        
        private func loadImage(from item: PhotosPickerItem?) async {
            guard let item = item else { return }
            
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data)?.cropToCenterSquare() {
                    await MainActor.run {
                        selectedImage = uiImage
                    }
                }
            } catch {
                print("Ошибка загрузки фото: \(error)")
            }
        }
    }
}

extension UIImage {
    func cropToCenterSquare() -> UIImage? {
        // Нормализуем ориентацию
        guard let cgImage = self.cgImage else { return nil }
        
        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)
        let minLength = min(originalWidth, originalHeight)
        
        let cropRect = CGRect(
            x: (originalWidth - minLength) / 2,
            y: (originalHeight - minLength) / 2,
            width: minLength,
            height: minLength
        )
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: .up)
    }
}
