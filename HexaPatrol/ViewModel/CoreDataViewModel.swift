import CoreData
import Combine

class CoreDataViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var patrolActivities: [CantPatrolModel] = []
    
    private let fetchedResultsController: NSFetchedResultsController<CantPatrolModel>
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let fetchRequest: NSFetchRequest<CantPatrolModel> = CantPatrolModel.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CantPatrolModel.date, ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            patrolActivities = fetchedResultsController.fetchedObjects ?? []
        } catch {
            print("❌ Error fetching data: \(error.localizedDescription)")
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let updatedActivities = controller.fetchedObjects as? [CantPatrolModel] else { return }
        DispatchQueue.main.async {
            self.patrolActivities = updatedActivities
            self.objectWillChange.send() // Notify SwiftUI of changes
        }
    }
    
    func addActivity(name: String, status: String) {
        let newActivity = CantPatrolModel(context: context)
        newActivity.name = name
        newActivity.status = status
        newActivity.date = Date()

        do {
            try context.save()
        } catch {
            print("❌ Failed to save activity: \(error.localizedDescription)")
        }
    }
}