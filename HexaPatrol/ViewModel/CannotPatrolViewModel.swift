//
//  CannotPatrolViewModel.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 16/02/25.
//


import SwiftUI
import CoreData
//
//class CannotPatrolViewModel: ObservableObject {
//    @Published var patrols: [CantPatrolModel] = []
//    private var context: NSManagedObjectContext
//
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        fetchPatrols()
//        
//        // Listen for changes in CannotPatrolModel
//        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: context, queue: .main) { _ in
//            self.fetchPatrols()
//        }
//    }
//
//    func fetchPatrols() {
//        let request: NSFetchRequest<CantPatrolModel> = CantPatrolModel.fetchRequest()
//        request.sortDescriptors = [NSSortDescriptor(keyPath: \CantPatrolModel.date, ascending: false)]
//        
//        do {
//            patrols = try context.fetch(request)
//        } catch {
//            print("Error fetching patrols: \(error.localizedDescription)")
//        }
//    }
//
//    func addPatrol(name: String, location: String, status: String) {
//        let newPatrol = CantPatrolModel(context: context)
//        newPatrol.name = name
//        newPatrol.location = location
//        newPatrol.status = status
//        newPatrol.date = Date()
//        
//        saveContext()
//        fetchPatrols()
//    }
//
//    func saveContext() {
//        if context.hasChanges {
//            do {
//                try context.save()
//                print("CannotPatrol data saved.")
//            } catch {
//                print("Error saving context: \(error.localizedDescription)")
//            }
//        }
//    }
//}

//class CantPatrolViewModel: ObservableObject {
//    @Published var isSubmitting = false
//    @Published var errorMessage = ""
//    @Published var showError = false
//    @Published var offlinePatrols: [CantPatrolModel] = []
//    
//    private let persistenceController = PersistenceController.shared
//    private var onceToken = OnceToken()
//    
//    // OnceToken class for ensuring operations run only once
//    class OnceToken {
//        private(set) var hasRun = false
//        
//        func checkAndSet() -> Bool {
//            if hasRun { return false }
//            hasRun = true
//            return true
//        }
//    }
//    
//    // Fetch all offline patrols
//    func fetchOfflinePatrols() {
//        let context = persistenceController.context
//        let fetchRequest: NSFetchRequest<CantPatrolModel> = CantPatrolModel.fetchRequest()
//        
//        do {
//            let results = try context.fetch(fetchRequest)
//            DispatchQueue.main.async {
//                self.offlinePatrols = results
//            }
//        } catch {
//            print("❌ Error fetching offline patrols: \(error.localizedDescription)")
//        }
//    }
//    
//    // Submit form to API
//    func submitCantPatrol(
//        name: String,
//        username: String,
//        department: String,
//        role: String,
//        userDate: String,
//        image: UIImage,
//        size: String,
//        status: String,
//        reason: String,
//        location: String,
//        lon: Decimal,
//        lat: Decimal,
//        reasonDate: String,
//        authViewModel: APIService // Assuming you have this
//    ) async -> Bool {
//        isSubmitting = true
//        
//        do {
//            try await authViewModel.postCantPatrol(
//                name: name,
//                username: username,
//                department: department,
//                role: role,
//                userDate: userDate,
//                image: image,
//                size: size,
//                status: status,
//                reason: reason,
//                location: location,
//                lon: lon,
//                lat: lat,
//                reasonDate: reasonDate
//            )
//            
//            await MainActor.run {
//                self.isSubmitting = false
//            }
//            return true
//        } catch {
//            await MainActor.run {
//                self.errorMessage = error.localizedDescription
//                self.showError = true
//                self.isSubmitting = false
//            }
//            return false
//        }
//    }
//    
//    // Check network and submit or save offline
//    func checkNetworkAndSubmit(
//        authViewModel: APIService,
//        cameraViewModel: CameraViewModel,
//        locationViewModel: LocationViewModel,
//        selectedStatus: String,
//        reason: String,
//        formattedDate: String,
//        completion: @escaping () -> Void
//    ) async {
//        do {
//            guard let image = cameraViewModel.selectedImage else {
//                throw NSError(domain: "FormError", code: 400, userInfo: [NSLocalizedDescriptionKey: "No image captured"])
//            }
//            
//            let monitor = NWPathMonitor()
//            let queue = DispatchQueue.global(qos: .background)
//            
//            monitor.pathUpdateHandler = { path in
//                Task {
//                    let shouldRun = self.onceToken.checkAndSet()
//                    if !shouldRun { return }
//                    
//                    if path.status == .satisfied {
//                        print("✅ Internet tersedia, mengirim data ke API...")
//                        do {
//                            let success = try await self.submitCantPatrol(
//                                name: authViewModel.user?.name ?? "",
//                                username: authViewModel.user?.email ?? "",
//                                department: authViewModel.user?.department ?? "",
//                                role: authViewModel.user?.role ?? "",
//                                userDate: formattedDate,
//                                image: image,
//                                size: "\(cameraViewModel.imageSize ?? 0)",
//                                status: selectedStatus,
//                                reason: reason,
//                                location: locationViewModel.locationName,
//                                lon: Decimal(locationViewModel.longitude ?? 0.0),
//                                lat: Decimal(locationViewModel.latitude ?? 0.0),
//                                reasonDate: formattedDate,
//                                authViewModel: authViewModel
//                            )
//                            
//                            if success {
//                                print("✅ Data berhasil dikirim ke API")
//                            }
//                        } catch {
//                            print("❌ Gagal mengirim data ke API: \(error)")
//                        }
//                    } else {
//                        print("🚫 Tidak ada internet, menyimpan ke Core Data")
//                        await self.saveOfflineData(
//                            image: image,
//                            authViewModel: authViewModel,
//                            locationViewModel: locationViewModel,
//                            selectedStatus: selectedStatus,
//                            reason: reason,
//                            imageSize: "\(cameraViewModel.imageSize ?? 0)"
//                        )
//                    }
//                    
//                    monitor.cancel()
//                    await MainActor.run {
//                        completion()
//                    }
//                }
//            }
//            
//            monitor.start(queue: queue)
//            
//        } catch {
//            await MainActor.run {
//                self.errorMessage = error.localizedDescription
//                self.showError = true
//                self.isSubmitting = false
//                completion()
//            }
//        }
//    }
//    
//    // Save data offline to Core Data
//    @MainActor
//    func saveOfflineData(
//        image: UIImage,
//        authViewModel: APIService,
//        locationViewModel: LocationViewModel,
//        selectedStatus: String,
//        reason: String,
//        imageSize: String
//    ) async {
//        let context = persistenceController.context
//        
//        // Create User entity
//        let user = User(context: context)
//        user.name = authViewModel.user?.name ?? "Unknown"
//        user.username = authViewModel.user?.email ?? ""
//        user.department = authViewModel.user?.department ?? ""
//        user.role = authViewModel.user?.role ?? ""
//        
//        // Create Photo entity
//        let photo = Photo(context: context)
//        photo.imageName = UUID().uuidString + ".jpg"
//        photo.imageData = image.jpegData(compressionQuality: 0.8)
//        photo.size = imageSize
//        photo.user = user
//        
//        // Create ReasonTransaction entity
//        let reasonTransaction = ReasonTransaction(context: context)
//        reasonTransaction.date = Date()
//        reasonTransaction.latitude = NSDecimalNumber(value: locationViewModel.latitude ?? 0.0) as Decimal
//        reasonTransaction.longitude = NSDecimalNumber(value: locationViewModel.longitude ?? 0.0) as Decimal
//        reasonTransaction.location = locationViewModel.locationName
//        reasonTransaction.name = authViewModel.user?.name ?? "Unknown"
//        reasonTransaction.reason = reason
//        reasonTransaction.status = selectedStatus
//        reasonTransaction.user = user
//        
//        // Create CantPatrolModel for tracking the stored data
//        let cantPatrol = CantPatrolModel(context: context)
//        cantPatrol.id = UUID()
//        cantPatrol.createdAt = Date()
//        cantPatrol.syncStatus = "pending"
//        
//        do {
//            try context.save()
//            print("✅ Data saved offline in Core Data")
//            
//            // Update the offlinePatrols list
//            self.fetchOfflinePatrols()
//        } catch {
//            print("❌ Failed to save offline data: \(error.localizedDescription)")
//        }
//    }
//    
//    // Sync offline data when internet is available
//    func syncOfflineData(authViewModel: APIService) async {
//        let context = persistenceController.context
//        let fetchRequest: NSFetchRequest<CantPatrolModel> = CantPatrolModel.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "syncStatus == %@", "pending")
//        
//        do {
//            let pendingPatrols = try context.fetch(fetchRequest)
//            
//            for patrol in pendingPatrols {
//                // Implement the logic to sync each patrol with the server
//                // You would need to fetch associated User, Photo, and ReasonTransaction
//                // and call your API with the data
//                
//                // Mark as synced after successful API call
//                patrol.syncStatus = "synced"
//            }
//            
//            try context.save()
//            self.fetchOfflinePatrols()
//        } catch {
//            print("❌ Failed to sync offline data: \(error.localizedDescription)")
//        }
//    }
//}
