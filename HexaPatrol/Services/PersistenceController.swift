//
//  PersistenceController.swift
//  HexaPatrol
//
//  Created by Jaya Handika Darussalam on 06/01/25.
//


import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HirarkiModel") // Ensure this is correct
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            } else {
                print("Successfully loaded Core Data model: \(storeDescription)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return container.viewContext
    }

    func saveContext() {
        let context = self.context
        if context.hasChanges {
            do {
                try context.save()
                NotificationCenter.default.post(name: .NSManagedObjectContextDidSave, object: context)
            } catch {
                let error = error as NSError
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
