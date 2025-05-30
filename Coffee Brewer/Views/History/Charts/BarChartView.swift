import SwiftUI
import Charts
import CoreData

struct BarChartView: View {
    let brews: [Brew]
    let xAxis: any ChartAxis
    let yAxis: any ChartAxis
    let color: Color
    
    private var aggregatedData: [(category: String, average: Double, count: Int)] {
        // Determine which axis is categorical and which is numeric
        let (categoryAxis, numericAxis) = if xAxis.axisType == .categorical {
            (xAxis, yAxis)
        } else {
            (yAxis, xAxis)
        }
        
        // Group brews by category
        var groups: [String: [Double]] = [:]
        
        for brew in brews {
            if let categoryValue = categoryAxis.extractValue(from: brew) as? CategoricalAxisValue,
               let numericValue = numericAxis.extractValue(from: brew) as? NumericAxisValue {
                groups[categoryValue.categoryName, default: []].append(numericValue.numericValue)
            }
        }
        
        // Calculate averages
        return groups.map { category, values in
            let average = values.reduce(0, +) / Double(values.count)
            return (category: category, average: average, count: values.count)
        }
        .sorted { $0.average > $1.average }
    }
    
    private var visibleBarCount: Int {
        return min(aggregatedData.count, 4)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                // Chart content (scrollable)
                Charts.Chart(aggregatedData, id: \.category) { item in
                if xAxis.axisType == .categorical {
                    BarMark(
                        x: .value(xAxis.displayName, item.category),
                        y: .value(yAxis.displayName, item.average)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.5), color.opacity(0.3),  .black.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(8)
                    .annotation(position: .top) {
                        Text(String(format: "%.1f", item.average))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                } else {
                    BarMark(
                        x: .value(xAxis.displayName, item.average),
                        y: .value(yAxis.displayName, item.category)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                    .annotation(position: .trailing) {
                        Text(String(format: "%.1f", item.average))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let text = value.as(String.self) {
                            Text(text)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(BrewerColors.textSecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(width: 70)
                                .padding(.top, 4)
                        } else if let number = value.as(Double.self) {
                            Text(String(format: "%.1f", number))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(BrewerColors.textSecondary)
                        }
                    }
                    AxisGridLine()
                        .foregroundStyle(BrewerColors.chartGrid)
                    AxisTick()
                        .foregroundStyle(BrewerColors.chartGrid)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel(anchor: .trailing) {
                        if let text = value.as(String.self) {
                            Text(text)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(BrewerColors.textSecondary)
                                .padding(.trailing, 4)
                        } else if let number = value.as(Double.self) {
                            Text(String(format: "%.1f", number))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(BrewerColors.textSecondary)
                                .padding(.trailing, 4)
                        }
                    }
                    AxisGridLine()
                        .foregroundStyle(BrewerColors.chartGrid)
                    AxisTick()
                        .foregroundStyle(BrewerColors.chartGrid)
                }
            }
            .chartScrollableAxes(xAxis.axisType == .categorical ? .horizontal : [])
            .chartXVisibleDomain(length: xAxis.axisType == .categorical ? visibleBarCount : aggregatedData.count)
            .frame(minWidth: 300)
            .frame(height: 250)
            .padding(.horizontal)
            .padding(.vertical, 8)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var brews: [Brew] = []
        
        var body: some View {
            GlobalBackground {
                VStack(spacing: 40) {
                    BarChartView(
                        brews: brews,
                        xAxis: CategoricalAxis(type: .roasterName),
                        yAxis: NumericAxis(type: .rating),
                        color: BrewerColors.espresso
                    )
                    .onAppear {
                        let context = PersistenceController.preview.container.viewContext
                        let roasters = ["Blue Bottle Co. and no", "Stumptown", "Intelligentsia", "Local Roaster"]
                        
                        for i in 0..<30 {
                            let brew = Brew(context: context)
                            brew.id = UUID()
                            brew.date = Date().addingTimeInterval(TimeInterval(-i * 86400))
                            brew.roasterName = roasters.randomElement()!
                            brew.rating = Int16.random(in: 1...5)
                            brew.recipeName = "Test Recipe \(i)"
                            brews.append(brew)
                        }
                    }
                    
                    BarChartView(
                        brews: brews,
                        xAxis: NumericAxis(type: .rating),
                        yAxis: CategoricalAxis(type: .roasterName),
                        color: BrewerColors.espresso
                    )
                    .onAppear {
                        let context = PersistenceController.preview.container.viewContext
                        let roasters = ["Blue Bottle Co. and no", "Stumptown", "Intelligentsia", "Local Roaster"]
                        
                        for i in 0..<30 {
                            let brew = Brew(context: context)
                            brew.id = UUID()
                            brew.date = Date().addingTimeInterval(TimeInterval(-i * 86400))
                            brew.roasterName = roasters.randomElement()!
                            brew.rating = Int16.random(in: 1...5)
                            brew.recipeName = "Test Recipe \(i)"
                            brews.append(brew)
                        }
                    }
                }
            }
        }
    }
    
    return PreviewWrapper()
}
