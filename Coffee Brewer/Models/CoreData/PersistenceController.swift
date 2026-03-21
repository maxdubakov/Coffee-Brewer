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
            
            // Only populate countries and templates for real app, not preview
            if !inMemory, let container = container {
                let backgroundContext = container.newBackgroundContext()
                CountryDataManager.shared.populateCountriesIfNeeded(in: backgroundContext)
                PourTemplate.seedBuiltInTemplates(in: backgroundContext)
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    static var sampleRoaster: Roaster {
        let roaster = preview.container.viewContext.registeredObjects.compactMap { $0 as? Roaster }.first!
        return roaster
    }
    
    static var sampleCoffee: Coffee {
        let coffee = preview.container.viewContext.registeredObjects.compactMap { $0 as? Coffee }
            .first(where: { $0.name == "Yirgacheffe Natural" })!
        return coffee
    }
    
    // For SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Populate countries for preview
        CountryDataManager.shared.populateCountriesForPreview(in: viewContext)
        
        // Fetch countries
        let countryFetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
        let countries = try? viewContext.fetch(countryFetchRequest)
        let ukraineCountry = countries?.first(where: { $0.name == "Ukraine" })
        let ethiopiaCountry = countries?.first(where: { $0.name == "Ethiopia" })
        let colombiaCountry = countries?.first(where: { $0.name == "Colombia" })
        let kenyaCountry = countries?.first(where: { $0.name == "Kenya" })
        let brazilCountry = countries?.first(where: { $0.name == "Brazil" })
        
        // Seed pour templates
        PourTemplate.seedBuiltInTemplates(in: viewContext)
        
        // MARK: - Roasters
        
        let madHeads = Roaster(context: viewContext)
        madHeads.id = UUID()
        madHeads.name = "Mad Heads"
        madHeads.country = ukraineCountry
        madHeads.location = "Kyiv"
        madHeads.foundedYear = 2000
        
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
        colombianRoaster.location = "Bogota"
        colombianRoaster.foundedYear = 2015
        
        let brazilianRoaster = Roaster(context: viewContext)
        brazilianRoaster.id = UUID()
        brazilianRoaster.name = "Brazil Specialty"
        brazilianRoaster.country = brazilCountry
        brazilianRoaster.location = "Sao Paulo"
        brazilianRoaster.foundedYear = 2012
        
        // MARK: - Grinders
        
        let niche = Grinder(context: viewContext)
        niche.id = UUID()
        niche.name = "Niche Zero"
        niche.type = "Electric"
        niche.from = 0
        niche.to = 50
        niche.step = 0.2
        
        let commandante = Grinder(context: viewContext)
        commandante.id = UUID()
        commandante.name = "Commandante C40"
        commandante.type = "Manual"
        
        // MARK: - Coffees (the new central entity)
        
        let yirgacheffe = Coffee(context: viewContext)
        yirgacheffe.id = UUID()
        yirgacheffe.name = "Yirgacheffe Natural"
        yirgacheffe.process = "Natural"
        yirgacheffe.roaster = brightBean
        yirgacheffe.country = ethiopiaCountry
        yirgacheffe.createdAt = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        
        let kenyaAA = Coffee(context: viewContext)
        kenyaAA.id = UUID()
        kenyaAA.name = "Kenya AA Nyeri"
        kenyaAA.process = "Washed"
        kenyaAA.roaster = nordRoaster
        kenyaAA.country = kenyaCountry
        kenyaAA.createdAt = Calendar.current.date(byAdding: .day, value: -20, to: Date())!
        
        let colombianWashed = Coffee(context: viewContext)
        colombianWashed.id = UUID()
        colombianWashed.name = "Huila Washed"
        colombianWashed.process = "Washed"
        colombianWashed.roaster = colombianRoaster
        colombianWashed.country = colombiaCountry
        colombianWashed.createdAt = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        
        let madHeadsBlend = Coffee(context: viewContext)
        madHeadsBlend.id = UUID()
        madHeadsBlend.name = "Morning Blend"
        madHeadsBlend.roaster = madHeads
        madHeadsBlend.createdAt = Calendar.current.date(byAdding: .day, value: -45, to: Date())!
        
        let brazilNatural = Coffee(context: viewContext)
        brazilNatural.id = UUID()
        brazilNatural.name = "Cerrado Natural"
        brazilNatural.process = "Natural"
        brazilNatural.roaster = brazilianRoaster
        brazilNatural.country = brazilCountry
        brazilNatural.createdAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        // MARK: - Helper to create brews with stages
        
        let calendar = Calendar.current
        let today = Date()
        
        func createStage(brew: Brew, type: String, waterAmount: Int16, orderIndex: Int16) {
            let stage = Stage(context: viewContext)
            stage.id = UUID()
            stage.type = type
            stage.waterAmount = waterAmount
            stage.orderIndex = orderIndex
            stage.brew = brew
        }
        
        func createBrew(
            coffee: Coffee,
            grinder: Grinder,
            brewMethod: String,
            grams: Int16,
            ratio: Double,
            waterAmount: Int16,
            temperature: Double,
            grindSize: Double,
            date: Date,
            rating: Int16,
            notes: String?,
            acidity: Int16,
            bitterness: Int16,
            body: Int16,
            sweetness: Int16,
            tds: Double?,
            isAssessed: Bool,
            stages: [(type: String, waterPct: Double)]
        ) -> Brew {
            let brew = Brew(context: viewContext)
            brew.id = UUID()
            brew.coffee = coffee
            brew.grinder = grinder
            brew.brewMethod = brewMethod
            brew.grams = grams
            brew.ratio = ratio
            brew.waterAmount = waterAmount
            brew.temperature = temperature
            brew.grindSize = grindSize
            brew.date = date
            brew.rating = rating
            brew.notes = notes
            brew.acidity = acidity
            brew.bitterness = bitterness
            brew.body = body
            brew.sweetness = sweetness
            brew.tds = tds ?? 0.0
            brew.isAssessed = isAssessed
            brew.roasterName = coffee.roaster?.name
            brew.grinderName = grinder.name
            
            for (index, stageInfo) in stages.enumerated() {
                let stageWater = Int16(Double(waterAmount) * stageInfo.waterPct / 100.0)
                createStage(brew: brew, type: stageInfo.type, waterAmount: stageWater, orderIndex: Int16(index))
            }
            
            return brew
        }
        
        // MARK: - Yirgacheffe brews (V60, iterating on pour pattern)
        
        let v60Stages: [(String, Double)] = [("fast", 20.0), ("slow", 80.0)]
        let v60ThreeStages: [(String, Double)] = [("fast", 20.0), ("slow", 40.0), ("fast", 40.0)]
        
        for i in stride(from: 0, to: 28, by: 3) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let rating = Int16.random(in: 3...5)
            let stages = i < 14 ? v60ThreeStages : v60Stages  // Changed pattern mid-bag
            let grindVariation = Double.random(in: -1.0...1.0)
            
            _ = createBrew(
                coffee: yirgacheffe,
                grinder: commandante,
                brewMethod: "V60",
                grams: 18,
                ratio: 15.0,
                waterAmount: 270,
                temperature: 93.0,
                grindSize: 28.0 + grindVariation,
                date: brewDate,
                rating: rating,
                notes: ["Fruity and bright", "Blueberry notes", "Clean finish", "Perfect extraction", nil].randomElement()!,
                acidity: Int16.random(in: 7...9),
                bitterness: Int16.random(in: 2...3),
                body: Int16.random(in: 5...7),
                sweetness: Int16.random(in: 6...8),
                tds: Double.random(in: 1.35...1.45),
                isAssessed: true,
                stages: stages
            )
        }
        
        // MARK: - Kenya AA brews (V60, morning routine)
        
        for i in stride(from: 1, to: 18, by: 2) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let brewTime = calendar.date(bySettingHour: 7, minute: 30, second: 0, of: brewDate)!
            let rating = Int16.random(in: 3...5)
            
            _ = createBrew(
                coffee: kenyaAA,
                grinder: commandante,
                brewMethod: "V60",
                grams: 19,
                ratio: 15.5,
                waterAmount: 295,
                temperature: 92.0,
                grindSize: 30.0,
                date: brewTime,
                rating: rating,
                notes: "Morning brew",
                acidity: Int16.random(in: 8...10),
                bitterness: Int16.random(in: 1...3),
                body: Int16.random(in: 4...6),
                sweetness: Int16.random(in: 5...7),
                tds: Double.random(in: 1.3...1.4),
                isAssessed: true,
                stages: v60Stages
            )
        }
        
        // MARK: - Colombian brews (Orea V4, dialing in)
        
        let oreaStages: [(String, Double)] = [("fast", 20.0), ("slow", 40.0), ("fast", 40.0)]
        
        for i in stride(from: 0, to: 12, by: 2) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let rating = Int16.random(in: 2...4)
            let grindAdjust = Double(i) * 0.5  // Gradually coarsening
            
            _ = createBrew(
                coffee: colombianWashed,
                grinder: niche,
                brewMethod: "Orea V4",
                grams: 20,
                ratio: 15.0,
                waterAmount: 300,
                temperature: 93.0,
                grindSize: 22.0 + grindAdjust,
                date: brewDate,
                rating: rating,
                notes: ["Still dialing in", "Getting closer", "Better than yesterday", "Channeling again", "Almost there"].randomElement()!,
                acidity: Int16.random(in: 5...7),
                bitterness: Int16.random(in: 3...6),
                body: Int16.random(in: 6...8),
                sweetness: Int16.random(in: 5...7),
                tds: Double.random(in: 1.3...1.42),
                isAssessed: true,
                stages: oreaStages
            )
        }
        
        // MARK: - Mad Heads Blend brews (V60, long history, consistent)
        
        for i in stride(from: 2, to: 40, by: 5) {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let rating = Int16.random(in: 3...4)
            
            _ = createBrew(
                coffee: madHeadsBlend,
                grinder: niche,
                brewMethod: "V60",
                grams: 18,
                ratio: 16.0,
                waterAmount: 288,
                temperature: 94.0,
                grindSize: 37.0,
                date: brewDate,
                rating: rating,
                notes: "Daily driver",
                acidity: Int16.random(in: 4...6),
                bitterness: Int16.random(in: 3...5),
                body: Int16.random(in: 5...7),
                sweetness: Int16.random(in: 5...7),
                tds: nil,
                isAssessed: true,
                stages: v60Stages
            )
        }
        
        // MARK: - Brazil Natural brews (new bag, just started)
        
        for i in [0, 1, 3, 5] {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            let rating = Int16.random(in: 3...5)
            
            _ = createBrew(
                coffee: brazilNatural,
                grinder: niche,
                brewMethod: "V60",
                grams: 20,
                ratio: 16.0,
                waterAmount: 320,
                temperature: 95.0,
                grindSize: 32.0,
                date: brewDate,
                rating: rating,
                notes: i == 0 ? "Chocolate and nuts, nice!" : "Testing parameters",
                acidity: Int16.random(in: 3...5),
                bitterness: Int16.random(in: 3...5),
                body: Int16.random(in: 7...9),
                sweetness: Int16.random(in: 5...7),
                tds: Double.random(in: 1.38...1.48),
                isAssessed: true,
                stages: v60Stages
            )
        }
        
        // MARK: - Unassessed brews (not yet rated)
        
        for i in [0, 2] {
            let brewDate = calendar.date(byAdding: .day, value: -i, to: today)!
            
            _ = createBrew(
                coffee: madHeadsBlend,
                grinder: niche,
                brewMethod: "V60",
                grams: 18,
                ratio: 16.0,
                waterAmount: 288,
                temperature: 94.0,
                grindSize: 37.0,
                date: brewDate,
                rating: 0,
                notes: nil,
                acidity: 0,
                bitterness: 0,
                body: 0,
                sweetness: 0,
                tds: nil,
                isAssessed: false,
                stages: v60Stages
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
