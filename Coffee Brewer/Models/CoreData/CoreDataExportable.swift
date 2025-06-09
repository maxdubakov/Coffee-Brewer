import Foundation
import CoreData

// MARK: - Recipe Export

extension Recipe {
    func export() -> [String: Any] {
        var data: [String: Any] = [
            "id": id?.uuidString ?? UUID().uuidString,
            "name": name ?? "",
            "grams": grams,
            "grindSize": grindSize,
            "ratio": ratio,
            "temperature": temperature,
            "waterAmount": waterAmount
        ]
        
        if let lastBrewedAt = lastBrewedAt {
            data["lastBrewedAt"] = ISO8601DateFormatter().string(from: lastBrewedAt)
        }
        
        if let roaster = roaster {
            data["roasterId"] = roaster.id?.uuidString ?? ""
            data["roasterName"] = roaster.name ?? ""
        }
        
        if let grinder = grinder {
            data["grinderId"] = grinder.id?.uuidString ?? ""
            data["grinderName"] = grinder.name ?? ""
        }
        
        if let stages = stages as? Set<Stage> {
            data["stages"] = stages
                .sorted { $0.orderIndex < $1.orderIndex }
                .map { $0.export() }
        }
        
        return data
    }
}

// MARK: - Brew Export

extension Brew {
    func export() -> [String: Any] {
        var data: [String: Any] = [
            "id": id?.uuidString ?? UUID().uuidString,
            "name": name ?? "",
            "rating": rating,
            "acidity": acidity,
            "bitterness": bitterness,
            "body": body,
            "sweetness": sweetness,
            "tds": tds,
            "actualDurationSeconds": actualDurationSeconds,
            "recipeGrams": recipeGrams,
            "recipeGrindSize": recipeGrindSize,
            "recipeRatio": recipeRatio,
            "recipeTemperature": recipeTemperature,
            "recipeWaterAmount": recipeWaterAmount
        ]
        
        if let date = date {
            data["date"] = ISO8601DateFormatter().string(from: date)
        }
        
        if let notes = notes, !notes.isEmpty {
            data["notes"] = notes
        }
        
        if let recipeName = recipeName {
            data["recipeName"] = recipeName
        }
        
        if let roasterName = roasterName {
            data["roasterName"] = roasterName
        }
        
        if let grinderName = grinderName {
            data["grinderName"] = grinderName
        }
        
        if let recipe = recipe {
            data["recipeId"] = recipe.id?.uuidString ?? ""
        }
        
        return data
    }
}

// MARK: - Roaster Export

extension Roaster {
    func export() -> [String: Any] {
        var data: [String: Any] = [
            "id": id?.uuidString ?? UUID().uuidString,
            "name": name ?? "",
            "foundedYear": foundedYear
        ]
        
        if let location = location, !location.isEmpty {
            data["location"] = location
        }
        
        if let website = website, !website.isEmpty {
            data["website"] = website
        }
        
        if let notes = notes, !notes.isEmpty {
            data["notes"] = notes
        }
        
        if let country = country {
            data["countryName"] = country.name ?? ""
        }
        
        return data
    }
}

// MARK: - Grinder Export

extension Grinder {
    func export() -> [String: Any] {
        var data: [String: Any] = [
            "id": id?.uuidString ?? UUID().uuidString,
            "name": name ?? "",
            "burrSize": burrSize
        ]
        
        if let type = type, !type.isEmpty {
            data["type"] = type
        }
        
        if let burrType = burrType, !burrType.isEmpty {
            data["burrType"] = burrType
        }
        
        if let dosingType = dosingType, !dosingType.isEmpty {
            data["dosingType"] = dosingType
        }
        
        return data
    }
}

// MARK: - Stage Export

extension Stage {
    func export() -> [String: Any] {
        return [
            "id": id?.uuidString ?? UUID().uuidString,
            "type": type ?? "",
            "orderIndex": orderIndex,
            "seconds": seconds,
            "waterAmount": waterAmount
        ]
    }
}

// MARK: - Chart Export

extension Chart {
    func export() -> [String: Any] {
        var data: [String: Any] = [
            "id": id?.uuidString ?? UUID().uuidString,
            "title": title ?? "",
            "chartType": chartType ?? "",
            "color": color ?? "",
            "isArchived": isArchived,
            "isExpanded": isExpanded,
            "sortOrder": sortOrder
        ]
        
        if let createdAt = createdAt {
            data["createdAt"] = ISO8601DateFormatter().string(from: createdAt)
        }
        
        if let updatedAt = updatedAt {
            data["updatedAt"] = ISO8601DateFormatter().string(from: updatedAt)
        }
        
        if let notes = notes, !notes.isEmpty {
            data["notes"] = notes
        }
        
        // X-Axis configuration
        if let xAxisId = xAxisId {
            data["xAxisId"] = xAxisId
        }
        if let xAxisType = xAxisType {
            data["xAxisType"] = xAxisType
        }
        if let xAxisDisplayName = xAxisDisplayName {
            data["xAxisDisplayName"] = xAxisDisplayName
        }
        
        // Y-Axis configuration
        if let yAxisId = yAxisId {
            data["yAxisId"] = yAxisId
        }
        if let yAxisType = yAxisType {
            data["yAxisType"] = yAxisType
        }
        if let yAxisDisplayName = yAxisDisplayName {
            data["yAxisDisplayName"] = yAxisDisplayName
        }
        
        return data
    }
}

// MARK: - Import Methods

extension Recipe {
    static func importFromData(_ data: [String: Any], context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
        // Check if recipe already exists
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if try context.count(for: request) == 0 {
            let recipe = Recipe(context: context)
            recipe.id = id
            recipe.name = data["name"] as? String ?? ""
            recipe.grams = Int16(data["grams"] as? Int ?? 0)
            recipe.grindSize = data["grindSize"] as? Double ?? 0.0
            recipe.ratio = data["ratio"] as? Double ?? 0.0
            recipe.temperature = data["temperature"] as? Double ?? 0.0
            recipe.waterAmount = Int16(data["waterAmount"] as? Int ?? 0)
            
            if let lastBrewedAtString = data["lastBrewedAt"] as? String {
                recipe.lastBrewedAt = ISO8601DateFormatter().date(from: lastBrewedAtString)
            }
            
            // Link to roaster if exists
            if let roasterIdString = data["roasterId"] as? String,
               let roasterId = UUID(uuidString: roasterIdString) {
                let roasterRequest: NSFetchRequest<Roaster> = Roaster.fetchRequest()
                roasterRequest.predicate = NSPredicate(format: "id == %@", roasterId as CVarArg)
                recipe.roaster = try context.fetch(roasterRequest).first
            }
            
            // Link to grinder if exists
            if let grinderIdString = data["grinderId"] as? String,
               let grinderId = UUID(uuidString: grinderIdString) {
                let grinderRequest: NSFetchRequest<Grinder> = Grinder.fetchRequest()
                grinderRequest.predicate = NSPredicate(format: "id == %@", grinderId as CVarArg)
                recipe.grinder = try context.fetch(grinderRequest).first
            }
            
            // Import stages for this recipe
            if let stages = data["stages"] as? [[String: Any]] {
                for stageData in stages {
                    _ = try Stage.importFromData(stageData, for: recipe, context: context)
                }
            }
            
            return true
        }
        
        return false
    }
}

extension Brew {
    static func importFromData(_ data: [String: Any], context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
        // Check if brew already exists
        let request: NSFetchRequest<Brew> = Brew.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if try context.count(for: request) == 0 {
            let brew = Brew(context: context)
            brew.id = id
            brew.name = data["name"] as? String ?? ""
            brew.rating = Int16(data["rating"] as? Int ?? 0)
            brew.acidity = Int16(data["acidity"] as? Int ?? 0)
            brew.bitterness = Int16(data["bitterness"] as? Int ?? 0)
            brew.body = Int16(data["body"] as? Int ?? 0)
            brew.sweetness = Int16(data["sweetness"] as? Int ?? 0)
            brew.tds = data["tds"] as? Double ?? 0.0
            brew.actualDurationSeconds = Int16(data["actualDurationSeconds"] as? Int ?? 0)
            brew.recipeGrams = Int16(data["recipeGrams"] as? Int ?? 0)
            brew.recipeGrindSize = data["recipeGrindSize"] as? Double ?? 0.0
            brew.recipeRatio = data["recipeRatio"] as? Double ?? 0.0
            brew.recipeTemperature = data["recipeTemperature"] as? Double ?? 0.0
            brew.recipeWaterAmount = Int16(data["recipeWaterAmount"] as? Int ?? 0)
            brew.notes = data["notes"] as? String
            brew.recipeName = data["recipeName"] as? String
            brew.roasterName = data["roasterName"] as? String
            brew.grinderName = data["grinderName"] as? String
            
            if let dateString = data["date"] as? String {
                brew.date = ISO8601DateFormatter().date(from: dateString)
            }
            
            // Link to recipe if exists
            if let recipeIdString = data["recipeId"] as? String,
               let recipeId = UUID(uuidString: recipeIdString) {
                let recipeRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
                recipeRequest.predicate = NSPredicate(format: "id == %@", recipeId as CVarArg)
                brew.recipe = try context.fetch(recipeRequest).first
            }
            
            return true
        }
        
        return false
    }
}

extension Roaster {
    static func importFromData(_ data: [String: Any], context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
        // Check if roaster already exists
        let request: NSFetchRequest<Roaster> = Roaster.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if try context.count(for: request) == 0 {
            let roaster = Roaster(context: context)
            roaster.id = id
            roaster.name = data["name"] as? String ?? ""
            roaster.foundedYear = Int16(data["foundedYear"] as? Int ?? 0)
            roaster.location = data["location"] as? String
            roaster.website = data["website"] as? String
            roaster.notes = data["notes"] as? String
            
            // Link to country by name if exists
            if let countryName = data["countryName"] as? String, !countryName.isEmpty {
                let countryRequest: NSFetchRequest<Country> = Country.fetchRequest()
                countryRequest.predicate = NSPredicate(format: "name == %@", countryName)
                roaster.country = try context.fetch(countryRequest).first
            }
            
            return true
        }
        
        return false
    }
}

extension Grinder {
    static func importFromData(_ data: [String: Any], context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
        // Check if grinder already exists
        let request: NSFetchRequest<Grinder> = Grinder.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if try context.count(for: request) == 0 {
            let grinder = Grinder(context: context)
            grinder.id = id
            grinder.name = data["name"] as? String ?? ""
            grinder.burrSize = Int16(data["burrSize"] as? Int ?? 0)
            grinder.type = data["type"] as? String
            grinder.burrType = data["burrType"] as? String
            grinder.dosingType = data["dosingType"] as? String
            
            return true
        }
        
        return false
    }
}

extension Stage {
    static func importFromData(_ data: [String: Any], for recipe: Recipe, context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
        // Check if stage already exists
        let request: NSFetchRequest<Stage> = Stage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if try context.count(for: request) == 0 {
            let stage = Stage(context: context)
            stage.id = id
            stage.type = data["type"] as? String ?? ""
            stage.orderIndex = Int16(data["orderIndex"] as? Int ?? 0)
            stage.seconds = Int16(data["seconds"] as? Int ?? 0)
            stage.waterAmount = Int16(data["waterAmount"] as? Int ?? 0)
            stage.recipe = recipe
            
            return true
        }
        
        return false
    }
}

extension Chart {
    static func importFromData(_ data: [String: Any], context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
        // Check if chart already exists
        let request: NSFetchRequest<Chart> = Chart.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if try context.count(for: request) == 0 {
            let chart = Chart(context: context)
            chart.id = id
            chart.title = data["title"] as? String ?? ""
            chart.chartType = data["chartType"] as? String ?? ""
            chart.color = data["color"] as? String ?? ""
            chart.isArchived = data["isArchived"] as? Bool ?? false
            chart.isExpanded = data["isExpanded"] as? Bool ?? true
            chart.sortOrder = Int32(data["sortOrder"] as? Int ?? 0)
            chart.notes = data["notes"] as? String
            chart.xAxisId = data["xAxisId"] as? String
            chart.xAxisType = data["xAxisType"] as? String
            chart.xAxisDisplayName = data["xAxisDisplayName"] as? String
            chart.yAxisId = data["yAxisId"] as? String
            chart.yAxisType = data["yAxisType"] as? String
            chart.yAxisDisplayName = data["yAxisDisplayName"] as? String
            
            if let createdAtString = data["createdAt"] as? String {
                chart.createdAt = ISO8601DateFormatter().date(from: createdAtString)
            }
            
            if let updatedAtString = data["updatedAt"] as? String {
                chart.updatedAt = ISO8601DateFormatter().date(from: updatedAtString)
            }
            
            return true
        }
        
        return false
    }
}
