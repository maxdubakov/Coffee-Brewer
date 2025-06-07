import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoffeeModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [weak container] description, error in
            if let error = error {
                fatalError("Error loading Core Data stores: \(error.localizedDescription)")
            }
            
            // Only populate countries for real app, not preview
            if !inMemory, let container = container {
                // Use a background context for population
                let backgroundContext = container.newBackgroundContext()
                CountryDataManager.shared.populateCountriesIfNeeded(in: backgroundContext)
                
                // Perform migration for existing brews
                PersistenceController.migrateExistingBrews(in: backgroundContext)
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Migration
    private static func migrateExistingBrews(in context: NSManagedObjectContext) {
        context.perform {
            let fetchRequest: NSFetchRequest<Brew> = Brew.fetchRequest()
            
            do {
                let brews = try context.fetch(fetchRequest)
                var migrationNeeded = false
                
                for brew in brews {
                    // Check if this brew needs migration
                    // If it has a rating or any taste profile data, mark it as assessed
                    if brew.rating > 0 || brew.acidity > 0 || brew.sweetness > 0 || 
                       brew.bitterness > 0 || brew.body > 0 || (brew.notes != nil && !brew.notes!.isEmpty) {
                        brew.isAssessed = true
                        migrationNeeded = true
                    }
                    // If no assessment data exists, it stays as unassessed (false by default)
                }
                
                if migrationNeeded {
                    try context.save()
                    print("Successfully migrated existing brews")
                }
            } catch {
                print("Error migrating brews: \(error)")
            }
        }
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
        
        // Populate countries for preview
        CountryDataManager.shared.populateCountriesForPreview(in: viewContext)
        
        // Fetch some countries for roasters
        let countryFetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
        let countries = try? viewContext.fetch(countryFetchRequest)
        let ukraineCountry = countries?.first(where: { $0.name == "Ukraine" })
        let ethiopiaCountry = countries?.first(where: { $0.name == "Ethiopia" })
        let colombiaCountry = countries?.first(where: { $0.name == "Colombia" })
        let kenyaCountry = countries?.first(where: { $0.name == "Kenya" })
        let guatemalaCountry = countries?.first(where: { $0.name == "Guatemala" })
        let brazilCountry = countries?.first(where: { $0.name == "Brazil" })
        
        // Create roasters
        let madHeads = Roaster(context: viewContext)
        madHeads.id = UUID()
        madHeads.name = "Mad Heads"
        madHeads.country = ukraineCountry
        madHeads.location = "Kyiv"
        madHeads.foundedYear = 2000
        
        let ethioRoaster = Roaster(context: viewContext)
        ethioRoaster.id = UUID()
        ethioRoaster.name = "Ethio Coffee Co."
        ethioRoaster.country = ethiopiaCountry
        
        // Create grinders
        let niche = Grinder(context: viewContext)
        niche.id = UUID()
        niche.name = "Niche Zero"
        niche.type = "Electric"
        
        let commandante = Grinder(context: viewContext)
        commandante.id = UUID()
        commandante.name = "Commandante C40"
        commandante.type = "Manual"
        
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
        createStage(recipe: ethiopianRecipe, type: "fast", waterAmount: 60, seconds: 10, orderIndex: 0) // Bloom
        createStage(recipe: ethiopianRecipe, type: "wait", waterAmount: 0, seconds: 45, orderIndex: 1) // Rest
        createStage(recipe: ethiopianRecipe, type: "slow", waterAmount: 140, seconds: 10, orderIndex: 2) // Slow pour
        createStage(recipe: ethiopianRecipe, type: "fast", waterAmount: 100, seconds: 10, orderIndex: 3) // Final pour
        
        // Create more roasters first
        let nordRoaster = Roaster(context: viewContext)
        nordRoaster.id = UUID()
        nordRoaster.name = "Nord Coffee Roasters"
        nordRoaster.country = kenyaCountry
        nordRoaster.location = "Nairobi"
        nordRoaster.foundedYear = 2018

        let brightBean = Roaster(context: viewContext)
        brightBean.id = UUID()
        brightBean.name = "Bright Bean Co."
        brightBean.country = ethiopiaCountry
        brightBean.location = "Addis Ababa"
        
        let colombianRoaster = Roaster(context: viewContext)
        colombianRoaster.id = UUID()
        colombianRoaster.name = "Cafe Colombia"
        colombianRoaster.country = colombiaCountry
        colombianRoaster.location = "Bogotá"
        colombianRoaster.foundedYear = 2015
        
        let guatemalanRoaster = Roaster(context: viewContext)
        guatemalanRoaster.id = UUID()
        guatemalanRoaster.name = "Antigua Coffee"
        guatemalanRoaster.country = guatemalaCountry
        guatemalanRoaster.location = "Antigua"
        guatemalanRoaster.foundedYear = 2010
        
        let brazilianRoaster = Roaster(context: viewContext)
        brazilianRoaster.id = UUID()
        brazilianRoaster.name = "Brazil Specialty"
        brazilianRoaster.country = brazilCountry
        brazilianRoaster.location = "São Paulo"
        brazilianRoaster.foundedYear = 2012
        
        // Now create Guatemala recipe with guatemalanRoaster
        let guatemalaRecipe = Recipe(context: viewContext)
        guatemalaRecipe.id = UUID()
        guatemalaRecipe.name = "Guatemala Espresso"
        guatemalaRecipe.grams = 18
        guatemalaRecipe.ratio = 2.0
        guatemalaRecipe.waterAmount = 36
        guatemalaRecipe.temperature = 95.0
        guatemalaRecipe.lastBrewedAt = Date() // Just now
        guatemalaRecipe.grindSize = 12
        guatemalaRecipe.roaster = guatemalanRoaster
        guatemalaRecipe.grinder = niche
        
        // Simple stage for espresso
        createStage(recipe: guatemalaRecipe, type: "slow", waterAmount: 36, seconds: 10, orderIndex: 0)

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

        createStage(recipe: nordKenya, type: "fast", waterAmount: 50, seconds: 10, orderIndex: 0)
        createStage(recipe: nordKenya, type: "wait", waterAmount: 0, seconds: 30, orderIndex: 1)
        createStage(recipe: nordKenya, type: "slow", waterAmount: 245, seconds: 10, orderIndex: 2)

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

        createStage(recipe: nordDecaf, type: "fast", waterAmount: 60, seconds: 10, orderIndex: 0)
        createStage(recipe: nordDecaf, type: "slow", waterAmount: 212, seconds: 10, orderIndex: 1)

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

        createStage(recipe: brightBlend, type: "fast", waterAmount: 40, seconds: 10, orderIndex: 0)
        createStage(recipe: brightBlend, type: "wait", waterAmount: 0, seconds: 20, orderIndex: 1)
        createStage(recipe: brightBlend, type: "slow", waterAmount: 200, seconds: 10, orderIndex: 2)

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

        createStage(recipe: brightEspresso, type: "fast", waterAmount: 40, seconds: 5, orderIndex: 0)
        
        // Add Colombian and Brazilian recipes
        let colombianPourOver = Recipe(context: viewContext)
        colombianPourOver.id = UUID()
        colombianPourOver.name = "Colombian V60"
        colombianPourOver.grams = 22
        colombianPourOver.ratio = 15.5
        colombianPourOver.waterAmount = 341
        colombianPourOver.temperature = 94.0
        colombianPourOver.lastBrewedAt = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        colombianPourOver.grindSize = 26
        colombianPourOver.roaster = colombianRoaster
        colombianPourOver.grinder = commandante
        
        createStage(recipe: colombianPourOver, type: "fast", waterAmount: 66, seconds: 15, orderIndex: 0)
        createStage(recipe: colombianPourOver, type: "wait", waterAmount: 0, seconds: 30, orderIndex: 1)
        createStage(recipe: colombianPourOver, type: "slow", waterAmount: 275, seconds: 20, orderIndex: 2)
        
        let brazilianChemex = Recipe(context: viewContext)
        brazilianChemex.id = UUID()
        brazilianChemex.name = "Brazil Chemex"
        brazilianChemex.grams = 30
        brazilianChemex.ratio = 16.0
        brazilianChemex.waterAmount = 480
        brazilianChemex.temperature = 96.0
        brazilianChemex.lastBrewedAt = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        brazilianChemex.grindSize = 35
        brazilianChemex.roaster = brazilianRoaster
        brazilianChemex.grinder = niche
        
        createStage(recipe: brazilianChemex, type: "fast", waterAmount: 90, seconds: 20, orderIndex: 0)
        createStage(recipe: brazilianChemex, type: "wait", waterAmount: 0, seconds: 40, orderIndex: 1)
        createStage(recipe: brazilianChemex, type: "slow", waterAmount: 390, seconds: 30, orderIndex: 2)
        
        // Create more comprehensive brews with all required fields
        let createDetailedBrew = { (recipe: Recipe, rating: Int16, date: Date, notes: String?, acidity: Int16, bitterness: Int16, body: Int16, sweetness: Int16, tds: Double?, isAssessed: Bool) in
            let brew = Brew(context: viewContext)
            brew.id = UUID()
            brew.recipe = recipe
            brew.rating = rating
            brew.date = date
            brew.notes = notes
            
            // Snapshot recipe data at time of brew
            brew.recipeName = recipe.name
            brew.recipeGrams = recipe.grams
            brew.recipeWaterAmount = recipe.waterAmount
            brew.recipeRatio = recipe.ratio
            brew.recipeTemperature = recipe.temperature
            brew.recipeGrindSize = recipe.grindSize
            brew.roasterName = recipe.roaster?.name
            brew.grinderName = recipe.grinder?.name
            
            // Actual brew duration (simulate variation from recipe)
            let stages = recipe.stages?.allObjects as? [Stage] ?? []
            let totalRecipeTime = stages.reduce(Int16(0)) { $0 + $1.seconds }
            brew.actualDurationSeconds = max(totalRecipeTime + Int16.random(in: -20...30), 60) // Minimum 60 seconds
            
            // Flavor profile
            brew.acidity = acidity
            brew.bitterness = bitterness
            brew.body = body
            brew.sweetness = sweetness
            brew.tds = tds ?? Double.random(in: 1.2...1.5)
            brew.isAssessed = isAssessed // Mark preview brews as assessed
        }
        
        // Create brews across the last 60 days for better analytics
        let calendar = Calendar.current
        let today = Date()
        
        // Ethiopian Pour Over brews - consistently good
        for i in stride(from: 0, to: 50, by: 7) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let rating = Int16.random(in: 4...5)
            let notes = ["Excellent balance", "Fruity and bright", "Clean finish", "Blueberry notes prominent", "Perfect extraction"].randomElement()
            
            createDetailedBrew(
                ethiopianRecipe,
                rating,
                brewDate,
                notes,
                Int16.random(in: 7...9),    // High acidity
                Int16.random(in: 2...3),    // Low bitterness
                Int16.random(in: 5...7),    // Medium body
                Int16.random(in: 6...8),    // Good sweetness
                Double.random(in: 1.35...1.45),
                true
            )
        }
        
        // Guatemala Espresso brews - variable results
        for i in stride(from: 2, to: 45, by: 5) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let rating = Int16.random(in: 2...4)
            let notes = ["Needs dialing in", "Better than yesterday", "Still bitter", "Getting closer", "Channeling again"].randomElement()
            
            createDetailedBrew(
                guatemalaRecipe,
                rating,
                brewDate,
                notes,
                Int16.random(in: 3...5),    // Medium acidity
                Int16.random(in: 6...9),    // High bitterness
                Int16.random(in: 7...9),    // Full body
                Int16.random(in: 2...4),    // Low sweetness
                Double.random(in: 1.2...1.3),
                true
            )
        }
        
        // Kenya V60 brews - morning routine
        for i in stride(from: 1, to: 30, by: 3) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let brewTime = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: brewDate)!
            let rating = Int16.random(in: 3...5)
            
            createDetailedBrew(
                nordKenya,
                rating,
                brewTime,
                "Morning brew",
                Int16.random(in: 8...10),   // Very high acidity
                Int16.random(in: 1...3),    // Very low bitterness
                Int16.random(in: 4...6),    // Light-medium body
                Int16.random(in: 5...7),    // Good sweetness
                Double.random(in: 1.3...1.4),
                true
            )
        }
        
        // Decaf brews - evening routine
        for i in stride(from: 0, to: 20, by: 2) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let brewTime = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: brewDate)!
            let rating = Int16.random(in: 3...4)
            
            createDetailedBrew(
                nordDecaf,
                rating,
                brewTime,
                "Evening decaf",
                Int16.random(in: 2...4),    // Low acidity
                Int16.random(in: 3...5),    // Medium bitterness
                Int16.random(in: 6...8),    // Good body
                Int16.random(in: 4...6),    // Medium sweetness
                nil,
                true
            )
        }
        
        // Morning Blend brews - weekend experiments
        for i in [0, 7, 14, 21, 28] {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            if calendar.isDateInWeekend(brewDate) {
                let rating = Int16.random(in: 3...5)
                let grindVariation = Int16.random(in: -2...2)
                
                createDetailedBrew(
                    brightBlend,
                    rating,
                    brewDate,
                    "Weekend experiment, grind: \(brightBlend.grindSize + grindVariation)",
                    Int16.random(in: 4...6),    // Medium acidity
                    Int16.random(in: 2...4),    // Low-medium bitterness
                    Int16.random(in: 5...7),    // Medium body
                    Int16.random(in: 6...8),    // Good sweetness
                    Double.random(in: 1.3...1.45),
                    true
                )
            }
        }
        
        // Default recipe brews - testing different parameters
        for i in stride(from: 3, to: 40, by: 8) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let rating = Int16.random(in: 2...5)
            
            createDetailedBrew(
                defaultRecipe,
                rating,
                brewDate,
                "Testing parameters",
                Int16.random(in: 3...7),    // Variable acidity
                Int16.random(in: 2...6),    // Variable bitterness
                Int16.random(in: 4...8),    // Variable body
                Int16.random(in: 3...7),    // Variable sweetness
                Double.random(in: 1.25...1.5),
                true
            )
        }
        
        // Add some recent bright espresso brews
        for i in [0, 1, 2, 5, 8] {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let rating = Int16.random(in: 3...5)
            
            createDetailedBrew(
                brightEspresso,
                rating,
                brewDate,
                i == 0 ? "Finally dialed in!" : "Still adjusting",
                Int16.random(in: 5...7),    // Medium-high acidity
                Int16.random(in: 3...5),    // Medium bitterness
                Int16.random(in: 8...10),   // Full body
                Int16.random(in: 4...6),    // Medium sweetness
                Double.random(in: 1.2...1.35),
                true
            )
        }
        
        // Add some unassessed brews (brews that were completed but not yet rated)
        for i in [0, 3, 6] {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            
            createDetailedBrew(
                defaultRecipe,
                0,  // No rating yet
                brewDate,
                nil,  // No notes
                0,    // No acidity assessment
                0,    // No bitterness assessment
                0,    // No body assessment
                0,    // No sweetness assessment
                nil,  // No TDS
                false // Not assessed
            )
        }
        
        // Colombian V60 brews - balanced profile
        for i in stride(from: 1, to: 35, by: 4) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let rating = Int16.random(in: 4...5)
            
            createDetailedBrew(
                colombianPourOver,
                rating,
                brewDate,
                "Balanced and sweet",
                Int16.random(in: 5...6),    // Medium acidity
                Int16.random(in: 2...3),    // Low bitterness
                Int16.random(in: 6...8),    // Good body
                Int16.random(in: 7...9),    // High sweetness
                Double.random(in: 1.35...1.42),
                true
            )
        }
        
        // Brazilian Chemex brews - chocolatey and nutty
        for i in stride(from: 0, to: 25, by: 3) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let rating = Int16.random(in: 3...5)
            
            createDetailedBrew(
                brazilianChemex,
                rating,
                brewDate,
                "Chocolate and nuts",
                Int16.random(in: 3...5),    // Low-medium acidity
                Int16.random(in: 3...5),    // Medium bitterness
                Int16.random(in: 7...9),    // Full body
                Int16.random(in: 5...7),    // Good sweetness
                Double.random(in: 1.38...1.48),
                true
            )
        }
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Error creating preview data: \(error.localizedDescription)")
        }
        
        return controller
    }()
}
