//
//  ReasonFormView.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 03/02/25.
//

import SwiftUI
import CoreData

struct ReasonFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @EnvironmentObject var authViewModel: APIService
    @StateObject private var locationViewModel = LocationViewModel()
    
    let user: User?
    
    @State private var selectedStatus = "Rain"
    @State private var reason = ""
    @State private var isSubmitting = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let statusOptions = ["Rain", "Technical Issue", "Urgent"]
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
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
                    Picker("Select Status", selection: $selectedStatus) {
                        ForEach(statusOptions, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Reason") {
                    TextEditor(text: $reason)
                        .frame(height: 100)
                }
                
                Section("Location") {
                    VStack(alignment: .leading, spacing: 4) {
                        if locationViewModel.locationName == "Getting location..." {
                            HStack {
                                Text("Getting location")
                                Spacer()
                                ProgressView()
                            }
                        } else {
                            Text(locationViewModel.locationName)
                        }
                        
                        if let lat = locationViewModel.latitude, let lon = locationViewModel.longitude {
                            Text("Lon: \(lon), Lat: \(lat)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Submit Reason")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        cameraViewModel.resetCamera()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        Task {
                            await submitForm()
                        }
                    }
                    .disabled(reason.isEmpty || isSubmitting)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func submitForm() async {
        isSubmitting = true
        
        do {
            // Get the actual image from cameraViewModel
            guard let image = cameraViewModel.selectedImage else {
                throw NSError(
                    domain: "FormError",
                    code: 400,
                    userInfo: [NSLocalizedDescriptionKey: "No image captured"]
                )
            }
            
            try await authViewModel.postCantPatrol(
                name: user?.name ?? "",
                username: user?.email ?? "",
                department: user?.department ?? "",
                role: user?.role ?? "",
                userDate: formattedDate,
                image: image,
                size: "\(cameraViewModel.imageSize ?? 0)",
                status: selectedStatus,
                reason: reason,
                location: locationViewModel.locationName,
                lon: Decimal(locationViewModel.longitude ?? 0.0),
                lat: Decimal(locationViewModel.latitude ?? 0.0),
                reasonDate: formattedDate
            )
            
            // Reset and dismiss on success
            await MainActor.run {
                cameraViewModel.resetCamera()
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
                isSubmitting = false
            }
        }
    }
}

//#Preview {
//    let mockUser = User(
//        id: UUID(),
//        email: "test@example.com",
//        name: "Test User",
//        phone: "1234567890",
//        department: "IT",
//        role: "SUPERVISOR",
//        isActive: true
//    )
//    
//    let mockCameraViewModel = CameraViewModel()
//    let mockAuthViewModel = AuthViewModel()
//    
//    return ReasonFormView(user: mockUser)
//        .environmentObject(mockCameraViewModel)
//        .environmentObject(mockAuthViewModel)
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
