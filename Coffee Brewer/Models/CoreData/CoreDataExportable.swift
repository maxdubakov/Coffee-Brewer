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
            data["countryId"] = country.id?.uuidString ?? ""
            data["countryName"] = country.name ?? ""
            data["countryFlag"] = country.flag ?? ""
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

// MARK: - Country Export

extension Country {
    func export() -> [String: Any] {
        return [
            "id": id?.uuidString ?? UUID().uuidString,
            "name": name ?? "",
            "flag": flag ?? ""
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