//
//  HexaPatrolApp.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import SwiftUI

@main
struct HexaPatrolApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject var cameraViewModel = CameraViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(authViewModel)
                .environmentObject(cameraViewModel)
        }
    }
}
