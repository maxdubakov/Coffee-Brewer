import Foundation
import CoreData

struct CategoricalAxis: ChartAxis {
    let type: CategoricalAxisType
    
    var id: String { type.rawValue }
    var displayName: String { type.displayName }
    var axisType: AxisType { .categorical }
    
    func extractValue(from brew: Brew) -> Any? {
        let categoryName: String? = switch type {
        case .roasterName:
            brew.roasterName
        case .grinderName:
            brew.grinderName
        case .recipeName:
            brew.recipeName
        case .country:
            extractCountry(from: brew)
        case .brewMethod:
            extractBrewMethod(from: brew)
        case .ratingCategory:
            categorizeRating(brew.rating)
        }
        
        return categoryName.map { CategoricalAxisValue(categoryName: $0) }
    }
    
    private func extractCountry(from brew: Brew) -> String? {
        // Try to get country from the recipe's roaster relationship
        if let recipe = brew.recipe,
           let roaster = recipe.roaster,
           let country = roaster.country {
            return country.name
        }
        return nil
    }
    
    private func extractBrewMethod(from brew: Brew) -> String? {
        // Extract brew method from recipe name or type
        // This is a simplified version - you might want to add a brew method field to Recipe
        if let recipeName = brew.recipeName?.lowercased() {
            if recipeName.contains("v60") { return "V60" }
            if recipeName.contains("chemex") { return "Chemex" }
            if recipeName.contains("aeropress") { return "AeroPress" }
            if recipeName.contains("french press") { return "French Press" }
            if recipeName.contains("espresso") { return "Espresso" }
            if recipeName.contains("pour over") { return "Pour Over" }
        }
        return "Other"
    }
    
    private func categorizeRating(_ rating: Int16) -> String {
        switch rating {
        case 0...1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Very Good"
        case 5: return "Excellent"
        default: return "Unrated"
        }
    }
    
    func categories(for brews: [Brew]) -> [String] {
        let categories = brews.compactMap { extractValue(from: $0) as? CategoricalAxisValue }
            .map { $0.categoryName }
        
        // Return unique categories, sorted
        return Array(Set(categories)).sorted()
    }
    
    func count(for category: String, in brews: [Brew]) -> Int {
        brews.filter { brew in
            if let value = extractValue(from: brew) as? CategoricalAxisValue {
                return value.categoryName == category
            }
            return false
        }.count
    }
}

extension CategoricalAxis {
    static var allAxes: [CategoricalAxis] {
        CategoricalAxisType.allCases.map { CategoricalAxis(type: $0) }
    }
}
