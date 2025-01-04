//
//  UserDetailsView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 29/12/24.
//

import SwiftUI

struct UserDetailsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    let user: User?

    var body: some View {
        VStack {
            if let user = user {
                List {
                    Section(header: Text("User Details")) {
                        UserInfoRow(label: "Name", value: user.name)
                        UserInfoRow(label: "Email", value: user.email)
                        UserInfoRow(label: "Department", value: user.department)
                        UserInfoRow(label: "Role", value: user.role)
                        UserInfoRow(label: "Is Active?", value: user.isActive ? "Active" : "Not Active")
                    }

                    // Check if the user role is Super Admin or Admin to display configuration options
                    if user.role == "Super Admin" || user.role == "Admin" {
                        ConfigurationPatrol(user: user)
                    }
                    
//                    Section {
//                        LogoutButton()
//                    }
                    
                    Section("") {
                        Button {
                            viewModel.logout()
                        } label: {
                            Text("Sign out")
                                .fontWeight(.semibold)
                                .font(.system(size: 14))
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            } else {
                Text("No user data available.")
                    .padding()
            }
        }
        .navigationTitle("Personal Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ConfigurationPatrol: View {
    let user: User

    var body: some View {
        Section(header: Text("Patrol Configuration")) {
            UserInfoRow(label: "Sequential checklist", value: user.sequentialChecklist ? "Yes" : "No")
            UserInfoRow(label: "Conditional sync", value: user.conditionalSync ? "Yes" : "No")
            UserInfoRow(label: "Multiple patrol", value: user.multiplePatrol ? "Yes" : "No")
        }
    }
}

#Preview {
    UserDetailsView(user: User(id: 1, name: "John Doe", email: "asdf@gmail.com", department: "Security", role: "Admin", isActive: true, sequentialChecklist: true, conditionalSync: false, multiplePatrol: true))
}
