//
//  ImagePicker.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 01/01/25.
//


import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CameraViewModel
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.viewModel.imagePicked(uiImage)
            } else {
                parent.viewModel.imagePicked(nil)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.viewModel.imagePicked(nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}