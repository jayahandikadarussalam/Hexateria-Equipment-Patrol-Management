import SwiftUI
import CoreData

struct ReasonFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var viewContext
    @StateObject private var locationViewModel = LocationViewModel()
    
    let capturedImage: UIImage
    let user: User?
    
    @State private var selectedStatus = "Rain"
    @State private var reason = ""
    @State private var isSubmitting = false
    
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
                    if let image = capturedImage {
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
                    if locationViewModel.locationName == "Getting location..." {
                        HStack {
                            Text("Getting location")
                            Spacer()
                            ProgressView()
                        }
                    } else {
                        Text(locationViewModel.locationName)
                    }
                }
            }
            .navigationTitle("Submit Reason")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        submitForm()
                    }
                    .disabled(reason.isEmpty || isSubmitting)
                }
            }
        }
    }
    
    func submitForm() {
        isSubmitting = true
        
        // Create the request body
        let requestBody: [String: Any] = [
            "user": [
                "username": user?.email ?? "",
                "department": user?.department ?? "",
                "role": user?.role?.lowercased() ?? "",
                "date": formattedDate,
                "status": "active"
            ],
            "photo": [
                "image_name": "image.jpg",
                "image_path": "", // This would be filled after image upload
                "mime_type": "image/jpeg",
                "size": "500"
            ],
            "reason_transactions": [
                "status": selectedStatus,
                "reason": reason,
                "location": locationViewModel.locationName,
                "date": formattedDate
            ]
        ]
        
        // Save to CoreData
        let reasonEntity = ReasonTransaction(context: viewContext)
        reasonEntity.status = selectedStatus
        reasonEntity.reason = reason
        reasonEntity.location = locationViewModel.locationName
        reasonEntity.date = Date()
        
        do {
            try viewContext.save()
            // Here you would typically make your API call with requestBody
            dismiss()
        } catch {
            print("Error saving to CoreData: \(error)")
        }
        
        isSubmitting = false
    }
}

// CoreData Model
class ReasonTransaction: NSManagedObject {
    @NSManaged var status: String
    @NSManaged var reason: String
    @NSManaged var location: String
    @NSManaged var date: Date
}