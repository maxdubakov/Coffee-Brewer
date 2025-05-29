import Foundation
import CoreData

enum AxisType: String, Codable {
    case numeric
    case categorical
    case temporal
}

enum ChartType: String, Codable {
    case scatterPlot
    case barChart
    case timeSeries
}

protocol ChartAxis {
    var id: String { get }
    var displayName: String { get }
    var axisType: AxisType { get }
    
    func extractValue(from brew: Brew) -> Any?
}

protocol NumericValue {
    var numericValue: Double { get }
}

protocol CategoricalValue {
    var categoryName: String { get }
}

protocol TemporalValue {
    var date: Date { get }
}

enum NumericAxisType: String, CaseIterable {
    case rating = "rating"
    case grindSize = "grindSize"
    case temperature = "temperature"
    case coffeeAmount = "coffeeAmount"
    case waterAmount = "waterAmount"
    case ratio = "ratio"
    case brewDuration = "brewDuration"
    case acidity = "acidity"
    case bitterness = "bitterness"
    case body = "body"
    case sweetness = "sweetness"
    case tds = "tds"
    
    var displayName: String {
        switch self {
        case .rating: return "Rating"
        case .grindSize: return "Grind Size"
        case .temperature: return "Temperature (°C)"
        case .coffeeAmount: return "Coffee (g)"
        case .waterAmount: return "Water (ml)"
        case .ratio: return "Ratio"
        case .brewDuration: return "Duration (s)"
        case .acidity: return "Acidity"
        case .bitterness: return "Bitterness"
        case .body: return "Body"
        case .sweetness: return "Sweetness"
        case .tds: return "TDS"
        }
    }
}

enum CategoricalAxisType: String, CaseIterable {
    case roasterName = "roasterName"
    case grinderName = "grinderName"
    case recipeName = "recipeName"
    case country = "country"
    case brewMethod = "brewMethod"
    case ratingCategory = "ratingCategory"
    
    var displayName: String {
        switch self {
        case .roasterName: return "Roaster"
        case .grinderName: return "Grinder"
        case .recipeName: return "Recipe"
        case .country: return "Country"
        case .brewMethod: return "Brew Method"
        case .ratingCategory: return "Rating Category"
        }
    }
}

enum TemporalAxisType: String, CaseIterable {
    case brewDate = "brewDate"
    case brewWeek = "brewWeek"
    case brewMonth = "brewMonth"
    case dayOfWeek = "dayOfWeek"
    case timeOfDay = "timeOfDay"
    
    var displayName: String {
        switch self {
        case .brewDate: return "Date"
        case .brewWeek: return "Week"
        case .brewMonth: return "Month"
        case .dayOfWeek: return "Day of Week"
        case .timeOfDay: return "Time of Day"
        }
    }
}

struct NumericAxisValue: NumericValue {
    let numericValue: Double
}

struct CategoricalAxisValue: CategoricalValue {
    let categoryName: String
}

struct TemporalAxisValue: TemporalValue {
    let date: Date
}