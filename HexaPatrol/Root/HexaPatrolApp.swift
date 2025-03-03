//
//  HexaPatrolApp.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import SwiftUI

@main
struct HexaPatrolApp: App {
    @StateObject private var authViewModel = APIService()
    @StateObject var cameraViewModel = CameraViewModel()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(authViewModel)
                .environmentObject(cameraViewModel)
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
