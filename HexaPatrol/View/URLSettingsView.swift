//
//  URLSettingsView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 11/02/25.
//

import SwiftUI

struct URLSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = URLItemViewModel()
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showAddURLAlert = false
    @State private var newURLName = ""
    @State private var newURLAddress = ""
    @State private var selectedURL: String = ""

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Predefined URLs")) {
                    List {
                        ForEach(viewModel.predefinedURLs) { urlItem in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(urlItem.name)
                                        .font(.headline)
                                    Text(urlItem.url)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if viewModel.selectedURL == urlItem.url {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if viewModel.updateSelectedURL(urlItem.url) {
                                    // Selection successful
                                    alertMessage = "API URL successfully updated!" // Pesan sukses
                                    showAlert = true
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                                        selectedURL = viewModel.selectedURL // 🔄 Paksa UI update
//                                    }
//                                    dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                        showAlert = false
                                    }
                                } else {
                                    alertMessage = "Invalid API URL format. URL must end with /api/ and be a valid IP address or localhost."
                                    showAlert = true
                                }
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                            }
                        }
                        .onDelete(perform: viewModel.deleteURL)
                    }
                }
                
                Section {
                    Button(action: {
                        showAddURLAlert = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New URL")
                        }
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        if viewModel.updateSelectedURL(viewModel.selectedURL) {
                            dismiss()
                        } else {
                            alertMessage = "Invalid API URL format. URL must end with /api/ and be a valid IP address or localhost."
                            showAlert = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("API URL Settings")
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
            )
            .alert("Add New URL", isPresented: $showAddURLAlert) {
                TextField("Name (e.g., Office)", text: $newURLName)
                TextField("URL (must end with /api/)", text: $newURLAddress)
                Button("Cancel", role: .cancel) {
                    newURLName = ""
                    newURLAddress = ""
                }
                Button("Add") {
                    if viewModel.addURL(name: newURLName, url: newURLAddress) {
                        newURLName = ""
                        newURLAddress = ""
                    } else {
                        alertMessage = "Invalid API URL format. URL must:\n- End with /api/\n- Use http:// or https://\n- Contain a valid IP address or localhost"
                        showAlert = true
                    }
                }
            } message: {
                Text("Please enter the URL details")
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    URLSettingsView()
}

//#Preview {
//    let mockViewModel = URLItemViewModel()
//    // Add custom preview data if needed
//    mockViewModel.predefinedURLs = [
//        URLItemModel(name: "Test Server", url: "http://test.example.com/api/"),
//        URLItemModel(name: "Development", url: "http://dev.example.com/api/")
//    ]
//    return URLSettingsView()
//}
