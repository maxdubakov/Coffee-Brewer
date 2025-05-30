import Foundation
import CoreData

struct ChartConfiguration: Identifiable, Codable {
    let id: UUID
    let xAxis: AxisConfiguration
    let yAxis: AxisConfiguration
    let chartType: ChartType
    var title: String
    var isExpanded: Bool = true
    var color: String? = nil
    
    init(xAxis: AxisConfiguration, yAxis: AxisConfiguration, title: String? = nil) {
        self.id = UUID()
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.chartType = ChartResolver.resolveChartType(xAxisType: xAxis.axisType, yAxisType: yAxis.axisType)
        self.title = title ?? "\(yAxis.displayName) by \(xAxis.displayName)"
        self.isExpanded = true
    }
}

struct AxisConfiguration: Codable, Equatable {
    let axisType: AxisType
    let axisId: String
    let displayName: String
    
    init(from axis: any ChartAxis) {
        self.axisType = axis.axisType
        self.axisId = axis.id
        self.displayName = axis.displayName
    }
    
    func createAxis() -> (any ChartAxis)? {
        switch axisType {
        case .numeric:
            return NumericAxisType(rawValue: axisId).map { NumericAxis(type: $0) }
        case .categorical:
            return CategoricalAxisType(rawValue: axisId).map { CategoricalAxis(type: $0) }
        case .temporal:
            return TemporalAxisType(rawValue: axisId).map { TemporalAxis(type: $0) }
        }
    }
}

struct ChartResolver {
    static func resolveChartType(xAxisType: AxisType, yAxisType: AxisType) -> ChartType {
        switch (xAxisType, yAxisType) {
        case (.numeric, .numeric):
            return .scatterPlot
        case (.categorical, .numeric), (.numeric, .categorical):
            return .barChart
        case (.temporal, .numeric), (.numeric, .temporal):
            return .timeSeries
        case (.categorical, .categorical):
            // Default to bar chart for categorical x categorical
            return .barChart
        case (.temporal, .categorical), (.categorical, .temporal):
            // Default to bar chart for mixed temporal/categorical
            return .barChart
        case (.temporal, .temporal):
            return .timeSeries
        }
    }
    
    static func recommendedConfigurations() -> [ChartConfiguration] {
        [
            // Popular configurations
            ChartConfiguration(
                xAxis: AxisConfiguration(from: TemporalAxis(type: .brewDate)),
                yAxis: AxisConfiguration(from: NumericAxis(type: .rating)),
                title: "Rating Over Time"
            ),
            ChartConfiguration(
                xAxis: AxisConfiguration(from: CategoricalAxis(type: .roasterName)),
                yAxis: AxisConfiguration(from: NumericAxis(type: .rating)),
                title: "Average Rating by Roaster"
            ),
            ChartConfiguration(
                xAxis: AxisConfiguration(from: NumericAxis(type: .grindSize)),
                yAxis: AxisConfiguration(from: NumericAxis(type: .rating)),
                title: "Rating vs Grind Size"
            ),
            ChartConfiguration(
                xAxis: AxisConfiguration(from: TemporalAxis(type: .dayOfWeek)),
                yAxis: AxisConfiguration(from: NumericAxis(type: .rating)),
                title: "Rating by Day of Week"
            ),
            ChartConfiguration(
                xAxis: AxisConfiguration(from: CategoricalAxis(type: .brewMethod)),
                yAxis: AxisConfiguration(from: NumericAxis(type: .coffeeAmount)),
                title: "Coffee Usage by Method"
            )
        ]
    }
}

// For persisting chart configurations
extension ChartConfiguration {
    static func encode(_ configurations: [ChartConfiguration]) -> Data? {
        try? JSONEncoder().encode(configurations)
    }
    
    static func decode(from data: Data) -> [ChartConfiguration]? {
        try? JSONDecoder().decode([ChartConfiguration].self, from: data)
    }
}