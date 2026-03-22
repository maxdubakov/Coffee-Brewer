import Foundation
import CoreData

// MARK: - Coffee Export

extension Coffee {
    func export() -> [String: Any] {
        var data: [String: Any] = [
            "id": id?.uuidString ?? UUID().uuidString,
            "name": name ?? ""
        ]
        
        if let createdAt = createdAt {
            data["createdAt"] = ISO8601DateFormatter().string(from: createdAt)
        }
        
        if let process = process, !process.isEmpty {
            data["process"] = process
        }
        
        if let notes = notes, !notes.isEmpty {
            data["notes"] = notes
        }
        
        if let roaster = roaster {
            data["roasterId"] = roaster.id?.uuidString ?? ""
            data["roasterName"] = roaster.name ?? ""
        }
        
        if let country = country {
            data["countryName"] = country.name ?? ""
        }
        
        return data
    }
    
    static func importFromData(_ data: [String: Any], context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
        let request: NSFetchRequest<Coffee> = Coffee.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if try context.count(for: request) == 0 {
            let coffee = Coffee(context: context)
            coffee.id = id
            coffee.name = data["name"] as? String ?? ""
            coffee.process = data["process"] as? String
            coffee.notes = data["notes"] as? String
            
            if let createdAtString = data["createdAt"] as? String {
                coffee.createdAt = ISO8601DateFormatter().date(from: createdAtString)
            }
            
            // Link to roaster if exists
            if let roasterIdString = data["roasterId"] as? String,
               let roasterId = UUID(uuidString: roasterIdString) {
                let roasterRequest: NSFetchRequest<Roaster> = Roaster.fetchRequest()
                roasterRequest.predicate = NSPredicate(format: "id == %@", roasterId as CVarArg)
                coffee.roaster = try context.fetch(roasterRequest).first
            }
            
            // Link to country by name if exists
            if let countryName = data["countryName"] as? String, !countryName.isEmpty {
                let countryRequest: NSFetchRequest<Country> = Country.fetchRequest()
                countryRequest.predicate = NSPredicate(format: "name == %@", countryName)
                coffee.country = try context.fetch(countryRequest).first
            }
            
            return true
        }
        
        return false
    }
}

// MARK: - Brew Export

extension Brew {
    func export() -> [String: Any] {
        var data: [String: Any] = [
            "id": id?.uuidString ?? UUID().uuidString,
            "brewMethod": brewMethod ?? "V60",
            "grams": grams,
            "grindSize": grindSize,
            "ratio": ratio,
            "temperature": temperature,
            "waterAmount": waterAmount,
            "rating": rating,
            "acidity": acidity,
            "bitterness": bitterness,
            "body": body,
            "sweetness": sweetness,
            "tds": tds,
            "isAssessed": isAssessed
        ]
        
        if let date = date {
            data["date"] = ISO8601DateFormatter().string(from: date)
        }
        
        if let name = name, !name.isEmpty {
            data["name"] = name
        }
        
        if let notes = notes, !notes.isEmpty {
            data["notes"] = notes
        }
        
        if let roasterName = roasterName, !roasterName.isEmpty {
            data["roasterName"] = roasterName
        }
        
        if let grinderName = grinderName, !grinderName.isEmpty {
            data["grinderName"] = grinderName
        }
        
        if let coffee = coffee {
            data["coffeeId"] = coffee.id?.uuidString ?? ""
        }
        
        if let grinder = grinder {
            data["grinderId"] = grinder.id?.uuidString ?? ""
        }
        
        // Export stages
        if let stages = stages as? Set<Stage>, !stages.isEmpty {
            data["stages"] = stages
                .sorted { $0.orderIndex < $1.orderIndex }
                .map { $0.export() }
        }
        
        return data
    }
    
    static func importFromData(_ data: [String: Any], context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
        let request: NSFetchRequest<Brew> = Brew.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if try context.count(for: request) == 0 {
            let brew = Brew(context: context)
            brew.id = id
            brew.name = data["name"] as? String
            brew.brewMethod = data["brewMethod"] as? String ?? "V60"
            brew.grams = Int16(data["grams"] as? Int ?? 0)
            brew.grindSize = data["grindSize"] as? Double ?? 0.0
            brew.ratio = data["ratio"] as? Double ?? 0.0
            brew.temperature = data["temperature"] as? Double ?? 0.0
            brew.waterAmount = Int16(data["waterAmount"] as? Int ?? 0)
            brew.rating = data["rating"] as? Double ?? 0.0
            brew.acidity = Int16(data["acidity"] as? Int ?? 0)
            brew.bitterness = Int16(data["bitterness"] as? Int ?? 0)
            brew.body = Int16(data["body"] as? Int ?? 0)
            brew.sweetness = Int16(data["sweetness"] as? Int ?? 0)
            brew.tds = data["tds"] as? Double ?? 0.0
            brew.isAssessed = data["isAssessed"] as? Bool ?? false
            brew.notes = data["notes"] as? String
            brew.roasterName = data["roasterName"] as? String
            brew.grinderName = data["grinderName"] as? String
            
            if let dateString = data["date"] as? String {
                brew.date = ISO8601DateFormatter().date(from: dateString)
            }
            
            // Link to coffee if exists
            if let coffeeIdString = data["coffeeId"] as? String,
               let coffeeId = UUID(uuidString: coffeeIdString) {
                let coffeeRequest: NSFetchRequest<Coffee> = Coffee.fetchRequest()
                coffeeRequest.predicate = NSPredicate(format: "id == %@", coffeeId as CVarArg)
                brew.coffee = try context.fetch(coffeeRequest).first
            }
            
            // Link to grinder if exists
            if let grinderIdString = data["grinderId"] as? String,
               let grinderId = UUID(uuidString: grinderIdString) {
                let grinderRequest: NSFetchRequest<Grinder> = Grinder.fetchRequest()
                grinderRequest.predicate = NSPredicate(format: "id == %@", grinderId as CVarArg)
                brew.grinder = try context.fetch(grinderRequest).first
            }
            
            // Import stages for this brew
            if let stages = data["stages"] as? [[String: Any]] {
                for stageData in stages {
                    _ = try Stage.importFromData(stageData, for: brew, context: context)
                }
            }
            
            return true
        }
        
        return false
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
    
    static func importFromData(_ data: [String: Any], context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
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
    
    static func importFromData(_ data: [String: Any], context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
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

// MARK: - Stage Export

extension Stage {
    func export() -> [String: Any] {
        return [
            "id": id?.uuidString ?? UUID().uuidString,
            "type": type ?? "",
            "orderIndex": orderIndex,
            "waterAmount": waterAmount
        ]
    }
    
    static func importFromData(_ data: [String: Any], for brew: Brew, context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
        let request: NSFetchRequest<Stage> = Stage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if try context.count(for: request) == 0 {
            let stage = Stage(context: context)
            stage.id = id
            stage.type = data["type"] as? String ?? ""
            stage.orderIndex = Int16(data["orderIndex"] as? Int ?? 0)
            stage.waterAmount = Int16(data["waterAmount"] as? Int ?? 0)
            stage.brew = brew
            
            return true
        }
        
        return false
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
    
    static func importFromData(_ data: [String: Any], context: NSManagedObjectContext) throws -> Bool {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString) else { return false }
        
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
