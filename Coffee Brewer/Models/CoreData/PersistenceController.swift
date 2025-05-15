import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoffeeModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data stores: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    static var sampleRoaster: Roaster {
        let roaster = preview.container.viewContext.registeredObjects.compactMap { $0 as? Roaster }.first!
        return roaster
    }
    
    // For SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create sample data
        let viewContext = controller.container.viewContext

        let madHeads = Roaster(context: viewContext)
        madHeads.name = "Mad Heads"
        
        let recipe1 = Recipe(context: viewContext)
        recipe1.name = "Default"
        recipe1.grams = 18
        recipe1.lastBrewedAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        recipe1.roaster = madHeads

        let niche = Grinder(context: viewContext)
        niche.name = "Niche"
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Error creating preview data: \(error.localizedDescription)")
        }
        
        return controller
    }()
}
