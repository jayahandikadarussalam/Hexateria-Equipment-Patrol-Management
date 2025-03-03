//
//  ReasonFormViewModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 26/02/25.
//

import SwiftUI
import CoreData

class ReasonFormViewModel: ObservableObject {
    @Published var selectedStatus = "Rain"
    @Published var reason = ""
    @Published var isSubmitting = false
    @Published var showError = false
    @Published var errorMessage = ""

    var onDismiss: (() -> Void)?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    func submitForm(apiService: APIService,
                    cameraViewModel: CameraViewModel,
                    locationViewModel: LocationViewModel,
                    user: User?,
                    viewContext: NSManagedObjectContext) async {
        await MainActor.run {
            isSubmitting = true
        }
        
        print("📸 Submitting form... Checking image.")

        guard let image = cameraViewModel.selectedImage else {
            print("❌ Error: No image captured at submitForm()")
            await MainActor.run {
                self.errorMessage = "No image captured"
                self.showError = true
                self.isSubmitting = false
            }
            return
        }

        // Always save to Core Data first, regardless of network status
        await saveToCoreData(viewContext: viewContext, user: user, cameraViewModel: cameraViewModel, locationViewModel: locationViewModel)
        
        // If connected, also send to API
        if NetworkMonitor.shared.isConnected {
            do {
                try await apiService.postCantPatrol(
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

                await MainActor.run {
                    print("✅ API submission successful.")
                }
            } catch {
                await MainActor.run {
                    print("⚠️ API Error, but data was saved locally: \(error.localizedDescription)")
                    self.errorMessage = "Data saved locally, but couldn't sync to server: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        } else {
            await MainActor.run {
                print("📱 Offline mode: Data saved locally only")
                self.errorMessage = "Data saved locally. Will sync when online."
                self.showError = true
            }
        }
    }

    private func saveToCoreData(viewContext: NSManagedObjectContext, user: User?, cameraViewModel: CameraViewModel, locationViewModel: LocationViewModel) async {
        let context = viewContext

        // Remove the outer do-catch since context.perform doesn't throw
        await context.perform { [weak self] in
            guard let self = self else { return }

            if context.persistentStoreCoordinator == nil {
                print("⚠️ Error: Context does not have a persistentStoreCoordinator")
                return
            }

            let newReason = CantPatrolModel(context: context)
            newReason.id = UUID()
            newReason.name = user?.name ?? "Unknown"
            newReason.username = user?.email ?? "Unknown"
            newReason.department = user?.department ?? "Unknown"
            newReason.role = user?.role ?? "Unknown"
            newReason.userDate = self.formattedDate
            newReason.status = self.selectedStatus
            newReason.reason = self.reason
            newReason.location = locationViewModel.locationName.isEmpty ? "Unknown Location" : locationViewModel.locationName

            // Set coordinates safely
            newReason.lon = NSDecimalNumber(value: locationViewModel.longitude ?? 0.0)
            newReason.lat = NSDecimalNumber(value: locationViewModel.latitude ?? 0.0)

            // Save image data
            if let image = cameraViewModel.selectedImage, let imageData = image.jpegData(compressionQuality: 0.5) {
                newReason.image = imageData
            } else {
                newReason.image = nil
            }

            newReason.reasonDate = self.formattedDate

            do {
                print("🔄 Attempting to save context...")
                try context.save()
                print("✅ Data saved successfully to Core Data")
                
                // Sync with main context if needed
                Task { @MainActor in
                    try? viewContext.save()
                }

                // Post notification to update HomeTabView
                Task { @MainActor in
                    NotificationCenter.default.post(name: NSNotification.Name("DataSaved"), object: nil)
                }

                // Log the saved data for verification
                let fetchRequest: NSFetchRequest<CantPatrolModel> = CantPatrolModel.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", newReason.id! as CVarArg)
                
                if let savedReason = try context.fetch(fetchRequest).first {
                    print("📄 RAW RESPONSE FROM CORE DATA:")
                    print("🆔 ID: \(String(describing: savedReason.id))")
                    print("👤 Name: \(savedReason.name ?? "nil")")
                    print("📧 Username: \(savedReason.username ?? "nil")")
                    print("📧 UserDate: \(savedReason.userDate ?? "nil")")
                    print("🏢 Department: \(savedReason.department ?? "nil")")
                    print("📌 Location: \(savedReason.location ?? "nil")")
                    print("📝 Reason: \(savedReason.reason ?? "nil")")
                    print("📌 Status: \(savedReason.status ?? "nil")")
                    print("📍 Lon: \(String(describing: savedReason.lon))")
                    print("📍 Lat: \(String(describing: savedReason.lat))")
                    print("🖼 Image Data Size: \(savedReason.image?.count ?? 0) bytes")
                } else {
                    print("❌ Failed to fetch saved data from Core Data")
                }

                // Update UI on the Main Thread
                Task { @MainActor in
                    self.isSubmitting = false
                    cameraViewModel.resetCamera()
                    self.onDismiss?()
                }
            } catch {
                print("❌ CORE DATA ERROR: \(error.localizedDescription)")

                Task { @MainActor in
                    self.errorMessage = "Failed to save offline: \(error.localizedDescription)"
                    self.showError = true
                    self.isSubmitting = false
                }
            }
        }
    }
}
