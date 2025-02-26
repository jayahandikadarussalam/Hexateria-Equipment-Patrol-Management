import SwiftUI
import CoreData

@MainActor
class ReasonFormViewModel: ObservableObject {
    @Published var selectedStatus = "Rain"
    @Published var reason = ""
    @Published var isSubmitting = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    let statusOptions = ["Rain", "Technical Issue", "Urgent"]
    
    private let apiService: APIService
    private let cameraViewModel: CameraViewModel
    private let locationViewModel: LocationViewModel
    private let user: User?
    
    init(apiService: APIService, cameraViewModel: CameraViewModel, locationViewModel: LocationViewModel, user: User?) {
        self.apiService = apiService
        self.cameraViewModel = cameraViewModel
        self.locationViewModel = locationViewModel
        self.user = user
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    func submitForm(dismiss: @escaping () -> Void) async {
        isSubmitting = true
        
        do {
            guard let image = cameraViewModel.selectedImage else {
                throw NSError(domain: "FormError", code: 400, userInfo: [NSLocalizedDescriptionKey: "No image captured"])
            }
            
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
            
            // Reset & dismiss on success
            cameraViewModel.resetCamera()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isSubmitting = false
        }
    }
}