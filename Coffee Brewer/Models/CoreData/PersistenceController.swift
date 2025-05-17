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
    
    static var sampleRecipe: Recipe {
        let recipe = preview.container.viewContext.registeredObjects.compactMap { $0 as? Recipe }
            .first(where: { $0.name == "Ethiopian Pour Over" })!
        return recipe
    }
    
    // For SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Create sample data
        let viewContext = controller.container.viewContext
        
        // Create roasters
        let madHeads = Roaster(context: viewContext)
        madHeads.name = "Mad Heads"
        
        let ethioRoaster = Roaster(context: viewContext)
        ethioRoaster.name = "Ethio Coffee Co."
        
        // Create grinders
        let niche = Grinder(context: viewContext)
        niche.name = "Niche Zero"
        
        let commandante = Grinder(context: viewContext)
        commandante.name = "Commandante C40"
        
        // Create a default recipe
        let defaultRecipe = Recipe(context: viewContext)
        defaultRecipe.name = "Default"
        defaultRecipe.grams = 18
        defaultRecipe.ratio = 16.0
        defaultRecipe.waterAmount = 288
        defaultRecipe.temperature = 94.0
        defaultRecipe.lastBrewedAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        defaultRecipe.grindSize = 37
        defaultRecipe.roaster = madHeads
        defaultRecipe.grinder = niche
        
        // Create a complete recipe with stages
        let ethiopianRecipe = Recipe(context: viewContext)
        ethiopianRecipe.name = "Ethiopian Pour Over"
        ethiopianRecipe.grams = 20
        ethiopianRecipe.ratio = 15.0
        ethiopianRecipe.waterAmount = 300
        ethiopianRecipe.temperature = 93.0
        ethiopianRecipe.lastBrewedAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        ethiopianRecipe.grindSize = 28
        ethiopianRecipe.roaster = ethioRoaster
        ethiopianRecipe.grinder = commandante
        
        // Helper function to create stages
        func createStage(recipe: Recipe, type: String, waterAmount: Int16, seconds: Int16, orderIndex: Int16) {
            let stage = Stage(context: viewContext)
            stage.type = type
            stage.waterAmount = waterAmount
            stage.seconds = seconds
            stage.orderIndex = orderIndex
            stage.recipe = recipe
        }
        
        // Add stages to Ethiopian recipe (Bloom-Rest-Pour-Pour sequence)
        createStage(recipe: ethiopianRecipe, type: "fast", waterAmount: 60, seconds: 0, orderIndex: 0) // Bloom
        createStage(recipe: ethiopianRecipe, type: "wait", waterAmount: 0, seconds: 45, orderIndex: 1) // Rest
        createStage(recipe: ethiopianRecipe, type: "slow", waterAmount: 140, seconds: 0, orderIndex: 2) // Slow pour
        createStage(recipe: ethiopianRecipe, type: "fast", waterAmount: 100, seconds: 0, orderIndex: 3) // Final pour
        
        // Create a third recipe
        let guatemalaRecipe = Recipe(context: viewContext)
        guatemalaRecipe.name = "Guatemala Espresso"
        guatemalaRecipe.grams = 18
        guatemalaRecipe.ratio = 2.0
        guatemalaRecipe.waterAmount = 36
        guatemalaRecipe.temperature = 95.0
        guatemalaRecipe.lastBrewedAt = Date() // Just now
        guatemalaRecipe.grindSize = 12
        guatemalaRecipe.roaster = madHeads
        guatemalaRecipe.grinder = niche
        
        // Simple stage for espresso
        createStage(recipe: guatemalaRecipe, type: "slow", waterAmount: 36, seconds: 0, orderIndex: 0)
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Error creating preview data: \(error.localizedDescription)")
        }
        
        return controller
    }()
}
