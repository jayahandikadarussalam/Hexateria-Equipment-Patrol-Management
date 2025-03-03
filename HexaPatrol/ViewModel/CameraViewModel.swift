    //
    //  CameraViewModel.swift
    //  HexaPatrol
    //
    //  Created by Jaya Handika Darussalam on 01/01/25.
    //

    import SwiftUI
    import Combine
    import PhotosUI
    import UniformTypeIdentifiers

    class CameraViewModel: ObservableObject {
        @Published var isShowingCamera = false
        @Published var selectedImage: UIImage?
        @Published var showReasonForm = false
        @Published var imageName: String?
        @Published var imageSize: Int?
        @Published var capturedImageData: Data?
        
        func showCamera() {
            isShowingCamera = true
        }
        
        func imagePicked(_ image: UIImage?) {
            selectedImage = image
            isShowingCamera = false
            if let image = image {
                processImage(image)
                showReasonForm = true
            }
        }
        
        func loadImage(from pickerItem: PhotosPickerItem?) {
            guard let pickerItem else { return }
            
            pickerItem.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let imageData):
                        if let imageData {
                            if let image = UIImage(data: imageData) {
                                self.selectedImage = image
                                self.processImage(image)
                            }
                        }
                    case .failure(let error):
                        print("Error loading image: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        private func processImage(_ image: UIImage) {
            // Dapatkan ukuran file
            if let jpegData = image.jpegData(compressionQuality: 0.5) {
                self.imageSize = jpegData.count // Ukuran dalam bytes
    //            self.imageMimeType = "image/jpeg"
            } else if let pngData = image.pngData() {
                self.imageSize = pngData.count
    //            self.imageMimeType = "image/png"
            } else {
                self.imageSize = nil
    //            self.imageMimeType = nil
            }
            
            // Buat nama file unik berdasarkan timestamp jika tidak ada
            self.imageName = "photo_\(Int(Date().timeIntervalSince1970)).png"
        }

        func resetCamera() {
            showReasonForm = false
            selectedImage = nil
            imageName = nil
            imageSize = nil
        }
    }
