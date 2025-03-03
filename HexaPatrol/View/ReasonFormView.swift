//
//  ReasonFormView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 03/02/25.
//

import SwiftUI
import CoreData
import Network

//struct ReasonFormView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var cameraViewModel: CameraViewModel
//    @EnvironmentObject var apiService: APIService
//    @StateObject private var locationViewModel = LocationViewModel()
//    @StateObject private var viewModel = ReasonFormViewModel()
//
//    let user: User?
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section("Photo") {
//                    if let image = cameraViewModel.selectedImage {
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(maxHeight: 200)
//                            .frame(maxWidth: .infinity)
//                    }
//                }
//
//                Section("Status") {
//                    Picker("Select Status", selection: $viewModel.selectedStatus) {
//                        ForEach(["Rain", "Technical Issue", "Urgent"], id: \.self) { status in
//                            Text(status).tag(status)
//                        }
//                    }
//                    .pickerStyle(.menu)
//                }
//
//                Section("Reason") {
//                    TextEditor(text: $viewModel.reason)
//                        .frame(height: 100)
//                }
//            }
//            .navigationTitle("Submit Reason")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        cameraViewModel.resetCamera()
//                        dismiss()
//                    }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Submit") {
//                        Task {
//                            await viewModel.submitForm(
//                                apiService: apiService,
//                                cameraViewModel: cameraViewModel,
//                                locationViewModel: locationViewModel,
//                                user: user
//                            )
//                        }
//                    }
//                    .disabled(viewModel.reason.isEmpty || viewModel.isSubmitting)
//                }
//            }
//            .alert("Error", isPresented: $viewModel.showError) {
//                Button("OK") { }
//            } message: {
//                Text(viewModel.errorMessage)
//            }
//        }
//        .onAppear {
//            viewModel.onDismiss = {
//                dismiss()  // Closure untuk dismiss dipanggil di View
//            }
//        }
//    }
//}

struct ReasonFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @EnvironmentObject var apiService: APIService
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var viewModel = ReasonFormViewModel()

    let user: User?

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    if let image = cameraViewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .frame(maxWidth: .infinity)
                    }
                }

                Section("Status") {
                    Picker("Select Status", selection: $viewModel.selectedStatus) {
                        ForEach(["Rain", "Technical Issue", "Urgent"], id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Reason") {
                    TextEditor(text: $viewModel.reason)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Submit Reason")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        Task {
                            await viewModel.submitForm(
                                apiService: apiService,
                                cameraViewModel: cameraViewModel,
                                locationViewModel: locationViewModel,
                                user: user,
                                viewContext: viewContext
                            )
                        }
                    }
                    .disabled(viewModel.reason.isEmpty || viewModel.isSubmitting)
                }
            }
        }
        .onAppear {
            viewModel.onDismiss = {
                dismiss()
            }
        }
    }
}

#Preview {
    let cameraViewModel = CameraViewModel()
    let apiService = APIService()
    
    return ReasonFormView(
        user: User(id: 1, name: "John Doe", email: "asdf@gmail.com", department: "Security", role: "Admin", isActive: true, sequentialChecklist: true, conditionalSync: false, multiplePatrol: true)
    )
    .environmentObject(cameraViewModel)
    .environmentObject(apiService)
    .environment(\.managedObjectContext, PersistenceController.shared.context)
}
