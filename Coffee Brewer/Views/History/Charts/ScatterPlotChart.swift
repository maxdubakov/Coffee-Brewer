import SwiftUI
import Charts
import CoreData

struct ScatterPlotChart: View {
    let brews: [Brew]
    let xAxis: any ChartAxis
    let yAxis: any ChartAxis
    
    var body: some View {
        Charts.Chart {
            ForEach(brews, id: \.objectID) { brew in
                if let xValue = xAxis.extractValue(from: brew as Brew) as? NumericAxisValue,
                   let yValue = yAxis.extractValue(from: brew as Brew) as? NumericAxisValue {
                    PointMark(
                        x: .value(xAxis.displayName, xValue.numericValue),
                        y: .value(yAxis.displayName, yValue.numericValue)
                    )
                    .foregroundStyle(BrewerColors.chartPrimary)
                    .symbolSize(120)
                    .symbol {
                        Circle()
                            .fill(BrewerColors.chartPrimary)
                            .frame(width: 10, height: 10)
                            .background(
                                Circle()
                                    .fill(BrewerColors.chartPrimary.opacity(0.2))
                                    .frame(width: 18, height: 18)
                            )
                    }
                }
            }
        }
        .chartXAxisLabel(position: .bottom, alignment: .center, spacing: 12) {
            Text(xAxis.displayName.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(BrewerColors.textPrimary)
                .tracking(1.5)
        }
        .chartYAxisLabel(position: .leading, alignment: .center, spacing: 20) {
            Text(yAxis.displayName.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(BrewerColors.textPrimary)
                .tracking(1.5)
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let number = value.as(Double.self),
                       let numeric = xAxis as? NumericAxis {
                        Text(numeric.formatValue(number))
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
                    if let number = value.as(Double.self),
                       let numeric = yAxis as? NumericAxis {
                        Text(numeric.formatValue(number))
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
        .frame(height: 250)
        .padding()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var brews: [Brew] = []
        
        var body: some View {
            GlobalBackground {
                ScatterPlotChart(
                    brews: brews,
                    xAxis: NumericAxis(type: .grindSize),
                    yAxis: NumericAxis(type: .rating)
                )
                .onAppear {
                    // Create mock data
                    let context = PersistenceController.preview.container.viewContext
                    
                    for i in 0..<20 {
                        let brew = Brew(context: context)
                        brew.id = UUID()
                        brew.date = Date().addingTimeInterval(TimeInterval(-i * 86400))
                        brew.recipeGrindSize = Int16.random(in: 10...30)
                        brew.rating = Int16.random(in: 1...5)
                        brew.recipeName = "Test Recipe \(i)"
                        brews.append(brew)
                    }
                }
            }
        }
    }
    
    return PreviewWrapper()
}
