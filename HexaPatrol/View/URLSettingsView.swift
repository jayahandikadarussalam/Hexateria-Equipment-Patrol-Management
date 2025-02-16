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
    @State private var showEditURLAlert = false
    
    @State private var newURLName = ""
    @State private var newURLAddress = ""
    
    @State private var editingIndex: Int? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Predefined URLs")) {
                    List {
                        ForEach(viewModel.predefinedURLs.indices, id: \.self) { index in
                            let urlItem = viewModel.predefinedURLs[index]
                            
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
                                    alertMessage = "API URL successfully updated!"
                                    showAlert = true
                                } else {
                                    alertMessage = "Invalid API URL format. URL must end with /api/ and be a valid IP address or localhost."
                                    showAlert = true
                                }
                            }
                            .swipeActions {
                                Button("Edit") {
                                    editingIndex = index
                                    newURLName = urlItem.name
                                    newURLAddress = urlItem.url
                                    showEditURLAlert = true
                                }
                                .tint(.orange)
                                
                                Button("Delete", role: .destructive) {
                                    viewModel.deleteURL(at: IndexSet(integer: index))
                                }
                            }
                        }
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
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            
            .alert("Notification", isPresented: $showAlert) {
                Button("OK") { showAlert = false }
            } message: {
                Text(alertMessage)
            }
            
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
                        alertMessage = "Invalid API URL format."
                        showAlert = true
                    }
                }
            } message: {
                Text("Please enter the URL details")
            }
            
            .alert("Edit URL", isPresented: $showEditURLAlert) {
                TextField("Name", text: $newURLName)
                TextField("URL", text: $newURLAddress)
                Button("Cancel", role: .cancel) {
                    editingIndex = nil
                }
                Button("Save") {
                    if let index = editingIndex {
                        if viewModel.updateURL(at: index, name: newURLName, url: newURLAddress) {
                            editingIndex = nil
                        } else {
                            alertMessage = "Invalid API URL format."
                            showAlert = true
                        }
                    }
                }
            } message: {
                Text("Edit the URL details")
            }
        }
    }
}

#Preview {
    URLSettingsView()
}
