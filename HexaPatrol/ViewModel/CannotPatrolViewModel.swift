import SwiftUI
import CoreData

class CannotPatrolViewModel: ObservableObject {
    @Published var patrols: [CannotPatrolModel] = []
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchPatrols()
        
        // Listen for changes in CannotPatrolModel
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: context, queue: .main) { _ in
            self.fetchPatrols()
        }
    }

    func fetchPatrols() {
        let request: NSFetchRequest<CannotPatrolModel> = CannotPatrolModel.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CannotPatrolModel.date, ascending: false)]
        
        do {
            patrols = try context.fetch(request)
        } catch {
            print("Error fetching patrols: \(error.localizedDescription)")
        }
    }

    func addPatrol(name: String, location: String, status: String) {
        let newPatrol = CannotPatrolModel(context: context)
        newPatrol.name = name
        newPatrol.location = location
        newPatrol.status = status
        newPatrol.date = Date()
        
        saveContext()
        fetchPatrols()
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("CannotPatrol data saved.")
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
}
