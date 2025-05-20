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
        madHeads.id = UUID()
        madHeads.name = "Mad Heads"
        
        let ethioRoaster = Roaster(context: viewContext)
        ethioRoaster.id = UUID()
        ethioRoaster.name = "Ethio Coffee Co."
        
        // Create grinders
        let niche = Grinder(context: viewContext)
        niche.id = UUID()
        niche.name = "Niche Zero"
        
        let commandante = Grinder(context: viewContext)
        commandante.id = UUID()
        commandante.name = "Commandante C40"
        
        // Create a default recipe
        let defaultRecipe = Recipe(context: viewContext)
        defaultRecipe.id = UUID()
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
        ethiopianRecipe.id = UUID()
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
            stage.id = UUID()
            stage.type = type
            stage.waterAmount = waterAmount
            stage.seconds = seconds
            stage.orderIndex = orderIndex
            stage.recipe = recipe
        }
        
        // Add stages to Ethiopian recipe (Bloom-Rest-Pour-Pour sequence)
        createStage(recipe: defaultRecipe, type: "fast", waterAmount: 60, seconds: 10, orderIndex: 0) // Bloom
        createStage(recipe: ethiopianRecipe, type: "fast", waterAmount: 60, seconds: 0, orderIndex: 0) // Bloom
        createStage(recipe: ethiopianRecipe, type: "wait", waterAmount: 0, seconds: 45, orderIndex: 1) // Rest
        createStage(recipe: ethiopianRecipe, type: "slow", waterAmount: 140, seconds: 0, orderIndex: 2) // Slow pour
        createStage(recipe: ethiopianRecipe, type: "fast", waterAmount: 100, seconds: 0, orderIndex: 3) // Final pour
        
        // Create a third recipe
        let guatemalaRecipe = Recipe(context: viewContext)
        guatemalaRecipe.id = UUID()
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
        
        let nordRoaster = Roaster(context: viewContext)
        nordRoaster.id = UUID()
        nordRoaster.name = "Nord Coffee Roasters"

        let brightBean = Roaster(context: viewContext)
        brightBean.id = UUID()
        brightBean.name = "Bright Bean Co."

        // Nord Roaster Recipes
        let nordKenya = Recipe(context: viewContext)
        nordKenya.id = UUID()
        nordKenya.name = "Kenya V60"
        nordKenya.grams = 19
        nordKenya.ratio = 15.5
        nordKenya.waterAmount = 295
        nordKenya.temperature = 92.0
        nordKenya.lastBrewedAt = Date()
        nordKenya.grindSize = 30
        nordKenya.roaster = nordRoaster
        nordKenya.grinder = commandante

        createStage(recipe: nordKenya, type: "fast", waterAmount: 50, seconds: 0, orderIndex: 0)
        createStage(recipe: nordKenya, type: "wait", waterAmount: 0, seconds: 30, orderIndex: 1)
        createStage(recipe: nordKenya, type: "slow", waterAmount: 245, seconds: 0, orderIndex: 2)

        let nordDecaf = Recipe(context: viewContext)
        nordDecaf.id = UUID()
        nordDecaf.name = "Decaf Dream"
        nordDecaf.grams = 17
        nordDecaf.ratio = 16.0
        nordDecaf.waterAmount = 272
        nordDecaf.temperature = 91.0
        nordDecaf.lastBrewedAt = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        nordDecaf.grindSize = 34
        nordDecaf.roaster = nordRoaster
        nordDecaf.grinder = niche

        createStage(recipe: nordDecaf, type: "fast", waterAmount: 60, seconds: 0, orderIndex: 0)
        createStage(recipe: nordDecaf, type: "slow", waterAmount: 212, seconds: 0, orderIndex: 1)

        // Bright Bean Recipes
        let brightBlend = Recipe(context: viewContext)
        brightBlend.id = UUID()
        brightBlend.name = "Morning Blend"
        brightBlend.grams = 16
        brightBlend.ratio = 15.0
        brightBlend.waterAmount = 240
        brightBlend.temperature = 93.5
        brightBlend.lastBrewedAt = Calendar.current.date(byAdding: .day, value: -4, to: Date())!
        brightBlend.grindSize = 32
        brightBlend.roaster = brightBean
        brightBlend.grinder = commandante

        createStage(recipe: brightBlend, type: "fast", waterAmount: 40, seconds: 0, orderIndex: 0)
        createStage(recipe: brightBlend, type: "wait", waterAmount: 0, seconds: 20, orderIndex: 1)
        createStage(recipe: brightBlend, type: "slow", waterAmount: 200, seconds: 0, orderIndex: 2)

        let brightEspresso = Recipe(context: viewContext)
        brightEspresso.id = UUID()
        brightEspresso.name = "Bright Espresso"
        brightEspresso.grams = 18
        brightEspresso.ratio = 2.2
        brightEspresso.waterAmount = 40
        brightEspresso.temperature = 94.0
        brightEspresso.lastBrewedAt = Date()
        brightEspresso.grindSize = 10
        brightEspresso.roaster = brightBean
        brightEspresso.grinder = niche

        createStage(recipe: brightEspresso, type: "slow", waterAmount: 40, seconds: 0, orderIndex: 0)
        
        // Create sample brews for the preview
       let createSampleBrew = { (recipe: Recipe, rating: Int16, date: Date, notes: String?) in
           let brew = Brew(context: viewContext)
           brew.id = UUID()
           brew.recipe = recipe
           brew.rating = rating
           brew.date = date
           brew.notes = notes
           
           // Add sample flavor profile attributes
           brew.acidity = Int16.random(in: 1...5)
           brew.bitterness = Int16.random(in: 1...5)
           brew.body = Int16.random(in: 1...5)
           brew.sweetness = Int16.random(in: 1...5)
       }
       
       // Create a few sample brews with different dates
       let calendar = Calendar.current
       let today = Date()
       let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
       let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
       let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
       
       createSampleBrew(
           ethiopianRecipe,
           5,
           today,
           "Wonderful fruity notes with hints of blueberry. Very clean finish."
       )
       
       createSampleBrew(
           guatemalaRecipe,
           3,
           yesterday,
           "A bit too bitter, might need to adjust the grind size next time."
       )
       
       createSampleBrew(
           nordKenya,
           4,
           twoDaysAgo,
           "Bright acidity with citrus notes. Could use a slightly longer bloom time."
       )
       
       createSampleBrew(
           brightEspresso,
           2,
           threeDaysAgo,
           "Channeling issues, need to distribute better."
       )
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Error creating preview data: \(error.localizedDescription)")
        }
        
        return controller
    }()
}
