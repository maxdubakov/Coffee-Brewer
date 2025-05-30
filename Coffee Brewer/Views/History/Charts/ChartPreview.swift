import SwiftUI
import Charts
import CoreData

struct ChartPreview: View {
    let xAxisConfiguration: AxisConfiguration?
    let yAxisConfiguration: AxisConfiguration?
    let chartType: ChartType
    let brews: [Brew]
    let color: Color
    
    var body: some View {
        VStack(spacing: 0) {
            if let xAxisConfig = xAxisConfiguration,
               let yAxisConfig = yAxisConfiguration,
               let xAxis = xAxisConfig.createAxis(),
               let yAxis = yAxisConfig.createAxis() {
                // Show actual chart with data
                actualChartView(xAxis: xAxis, yAxis: yAxis)
            } else {
                // Show placeholder
                placeholderView
            }
        }
    }
    
    @ViewBuilder
    private func actualChartView(xAxis: any ChartAxis, yAxis: any ChartAxis) -> some View {
        switch chartType {
        case .scatterPlot:
            ScatterPlotChart(brews: brews, xAxis: xAxis, yAxis: yAxis, color: color)
        case .barChart:
            BarChartView(brews: brews, xAxis: xAxis, yAxis: yAxis, color: color)
        case .timeSeries:
            TimeSeriesChart(brews: brews, xAxis: xAxis, yAxis: yAxis, color: color)
        }
    }
    
    private var placeholderView: some View {
        Charts.Chart {
            // Empty chart with just the grid
        }
        .chartXAxisLabel(position: .bottom, alignment: .center, spacing: 12) {
            Text(xAxisConfiguration?.displayName.uppercased() ?? "SELECT X-AXIS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(xAxisConfiguration != nil ? BrewerColors.textPrimary : BrewerColors.textSecondary)
                .tracking(1.5)
        }
        .chartYAxisLabel(position: .leading, alignment: .center, spacing: 20) {
            Text(yAxisConfiguration?.displayName.uppercased() ?? "SELECT Y-AXIS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(yAxisConfiguration != nil ? BrewerColors.textPrimary : BrewerColors.textSecondary)
                .tracking(1.5)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                AxisValueLabel {
                    Text("")
                }
                AxisGridLine()
                    .foregroundStyle(BrewerColors.chartGrid)
                AxisTick()
                    .foregroundStyle(BrewerColors.chartGrid)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: 1)) { value in
                AxisValueLabel(anchor: .trailing) {
                    Text("")
                }
                AxisGridLine()
                    .foregroundStyle(BrewerColors.chartGrid)
                AxisTick()
                    .foregroundStyle(BrewerColors.chartGrid)
            }
        }
        .chartXScale(domain: 0...10)
        .chartYScale(domain: 0...10)
        .frame(height: 250)
        .padding()
        .overlay(
            Group {
                if xAxisConfiguration == nil || yAxisConfiguration == nil {
                    VStack(spacing: 8) {
                        Image(systemName: iconForChartType(chartType))
                            .font(.system(size: 40))
                            .foregroundColor(BrewerColors.textSecondary.opacity(0.3))
                        Text("Select both axes to preview")
                            .font(.caption)
                            .foregroundColor(BrewerColors.textSecondary.opacity(0.5))
                    }
                }
            }
        )
    }
    
    private func iconForChartType(_ type: ChartType) -> String {
        switch type {
        case .scatterPlot:
            return "chart.dots.scatter"
        case .barChart:
            return "chart.bar"
        case .timeSeries:
            return "chart.line.uptrend.xyaxis"
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var brews: [Brew] = []
        
        var body: some View {
            GlobalBackground {
                VStack(spacing: 20) {
                    ChartPreview(
                        xAxisConfiguration: nil,
                        yAxisConfiguration: nil,
                        chartType: .scatterPlot,
                        brews: brews,
                        color: BrewerColors.chartPrimary
                    )
                    .padding()
                    
                    ChartPreview(
                        xAxisConfiguration: AxisConfiguration(from: NumericAxis(type: .grindSize)),
                        yAxisConfiguration: AxisConfiguration(from: NumericAxis(type: .rating)),
                        chartType: .scatterPlot,
                        brews: brews,
                        color: BrewerColors.chartPrimary
                    )
                    .padding()
                }
                .onAppear {
                    // Create sample data for preview
                    let context = PersistenceController.preview.container.viewContext
                    
                    for i in 0..<15 {
                        let brew = Brew(context: context)
                        brew.id = UUID()
                        brew.date = Date().addingTimeInterval(TimeInterval(-i * 86400))
                        brew.recipeGrindSize = Int16.random(in: 10...30)
                        brew.rating = Int16.random(in: 2...5)
                        brew.recipeName = "Sample Recipe \(i)"
                        brew.roasterName = ["Blue Bottle", "Stumptown", "Intelligentsia"].randomElement()!
                        brews.append(brew)
                    }
                }
            }
        }
    }
    
    return PreviewWrapper()
}