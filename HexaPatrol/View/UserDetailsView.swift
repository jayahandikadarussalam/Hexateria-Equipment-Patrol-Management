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
    @State private var showSignOutConfirmation = false

    var body: some View {
        VStack {
            if let user = user {
                List {
                    Section {
                        HStack {
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray3))
                                .clipShape(Circle(), style: FillStyle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                Text(user.email)
                                    .font(.footnote)
                                    .accentColor(.gray)
                            }
                        }
                    }
                    Section(header: Text("User Details")) {
                        UserInfoRow(label: "Department", value: user.department)
                        UserInfoRow(label: "Role", value: user.role)
                        UserInfoRow(label: "Is Active?", value: user.isActive ? "Active" : "Not Active")
                    }

                    // Check if the user role is Super Admin or Admin to display configuration options
                    if user.role == "Super Admin" || user.role == "Admin" {
                        ConfigurationPatrol(user: user)
                    }
                    
                    Section("About the App") {
                        HStack {
                            Text("App Version")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("1.0.0 (1)")
                                .font(.system(size: 14))
                        }
                    }
                    
                    Button {
                        showSignOutConfirmation = true
                    } label: {
                        Text("Sign out")
                            .fontWeight(.semibold)
                            .font(.system(size: 14))
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .alert("Sign Out", isPresented: $showSignOutConfirmation) {
                    Button("Cancel", role: .cancel) {}
                    Button("Sign Out", role: .destructive) {
//                        viewModel.logout()
                        Task {
                            await viewModel.logout()
                        }
                    }
                } message: {
                    Text("Are you sure you want to sign out?")
                }
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
            UserInfoRow(label: "Sequential Checklist", value: user.sequentialChecklist ? "Yes" : "No")
            UserInfoRow(label: "Conditional Sync", value: user.conditionalSync ? "Yes" : "No")
            UserInfoRow(label: "Multiple Patrol", value: user.multiplePatrol ? "Yes" : "No")
        }
    }
}

#Preview {
    UserDetailsView(user: User(id: 1, name: "John Doe", email: "asdf@gmail.com", department: "Security", role: "Admin", isActive: true, sequentialChecklist: true, conditionalSync: false, multiplePatrol: true))
}
