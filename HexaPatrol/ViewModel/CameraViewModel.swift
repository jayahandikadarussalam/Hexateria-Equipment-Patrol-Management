//
//  CameraViewModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 01/01/25.
//


import SwiftUI
import Combine

class CameraViewModel: ObservableObject {
    @Published var isShowingCamera = false
    @Published var selectedImage: UIImage?
    
    func showCamera() {
        isShowingCamera = true
    }
    
    func imagePicked(_ image: UIImage?) {
        selectedImage = image
        isShowingCamera = false
    }
}