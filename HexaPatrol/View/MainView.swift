//
//  ContentView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Group {
            
            if viewModel.isLoggedIn {
                UserInfoView(user: viewModel.user)
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: viewModel.isLoggedIn)
//        .onAppear {
//            print("MainView appeared, isLoggedIn: \(viewModel.isLoggedIn)")
//        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
        .environmentObject(CameraViewModel())
}
