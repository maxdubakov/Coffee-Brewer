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
        
        let recipe2 = Recipe(context: viewContext)
        recipe2.name = "Default + longer"
        recipe2.grams = 20
        recipe2.lastBrewedAt = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        recipe2.roaster = madHeads
        
        let recipe3 = Recipe(context: viewContext)
        recipe3.name = "2S2R"
        recipe3.grams = 22
        recipe3.lastBrewedAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        recipe3.roaster = madHeads
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Error creating preview data: \(error.localizedDescription)")
        }
        
        return controller
    }()
}
