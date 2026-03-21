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
            brew.coffeeName
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
        brew.coffee?.roaster?.country?.name
    }

    private func extractBrewMethod(from brew: Brew) -> String? {
        if let method = brew.brewMethod, !method.isEmpty {
            return method
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
