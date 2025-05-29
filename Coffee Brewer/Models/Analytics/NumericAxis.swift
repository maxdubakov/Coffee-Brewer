import Foundation
import CoreData

struct NumericAxis: ChartAxis {
    let type: NumericAxisType
    
    var id: String { type.rawValue }
    var displayName: String { type.displayName }
    var axisType: AxisType { .numeric }
    
    func extractValue(from brew: Brew) -> Any? {
        let value: Double? = switch type {
        case .rating:
            Double(brew.rating)
        case .grindSize:
            Double(brew.recipeGrindSize)
        case .temperature:
            brew.recipeTemperature
        case .coffeeAmount:
            Double(brew.recipeGrams)
        case .waterAmount:
            Double(brew.recipeWaterAmount)
        case .ratio:
            brew.recipeRatio
        case .brewDuration:
            Double(brew.actualDurationSeconds)
        case .acidity:
            Double(brew.acidity)
        case .bitterness:
            Double(brew.bitterness)
        case .body:
            Double(brew.body)
        case .sweetness:
            Double(brew.sweetness)
        case .tds:
            brew.tds
        }
        
        return value.map { NumericAxisValue(numericValue: $0) }
    }
    
    func range(for brews: [Brew]) -> ClosedRange<Double>? {
        let values = brews.compactMap { extractValue(from: $0) as? NumericAxisValue }
            .map { $0.numericValue }
        
        guard !values.isEmpty else { return nil }
        
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        
        // Add some padding for better visualization
        let padding = (max - min) * 0.1
        return (min - padding)...(max + padding)
    }
    
    // Helper to format values for display
    func formatValue(_ value: Double) -> String {
        switch type {
        case .rating:
            return String(format: "%.1f", value)
        case .grindSize, .coffeeAmount, .waterAmount, .brewDuration:
            return String(format: "%.0f", value)
        case .temperature, .ratio, .tds:
            return String(format: "%.1f", value)
        case .acidity, .bitterness, .body, .sweetness:
            return String(format: "%.0f", value)
        }
    }
}

extension NumericAxis {
    static var allAxes: [NumericAxis] {
        NumericAxisType.allCases.map { NumericAxis(type: $0) }
    }
}