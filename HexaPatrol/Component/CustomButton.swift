//
//  CustomButton.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 30/12/24.
//

import SwiftUI

// Custom Button component
struct CustomButton: View {
    let title: String
    let textColor: Color
    let action: () -> Void
    
    init(
        title: String,
        textColor: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.textColor = textColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(textColor)
                .font(.system(size: 12))
                .fontWeight(.semibold)
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(UIColor.systemBackground))
        .listRowBackground(Color(UIColor.systemBackground))
    }
}

// Logout Button component
struct LogoutButton: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        CustomButton(
            title: "Sign Out",
            action: {
//                authViewModel.logout()
                Task {
                    await authViewModel.logout()
                }
            }
        )
    }
}

#Preview {
    LogoutButton()
        .environmentObject(AuthViewModel())
}
