import SwiftUI
import Charts

struct ChartPreview: View {
    let xAxisTitle: String?
    let yAxisTitle: String?
    let chartType: ChartType
    
    var body: some View {
        VStack(spacing: 0) {
            // Chart content matching the exact styling from real charts
            Charts.Chart {
                // Empty chart with just the grid
            }
            .chartXAxisLabel(position: .bottom, alignment: .center, spacing: 12) {
                Text(xAxisTitle?.uppercased() ?? "SELECT X-AXIS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(xAxisTitle != nil ? BrewerColors.textPrimary : BrewerColors.textSecondary)
                    .tracking(1.5)
            }
            .chartYAxisLabel(position: .leading, alignment: .center, spacing: 20) {
                Text(yAxisTitle?.uppercased() ?? "SELECT Y-AXIS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(yAxisTitle != nil ? BrewerColors.textPrimary : BrewerColors.textSecondary)
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
                    if xAxisTitle == nil || yAxisTitle == nil {
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
    GlobalBackground {
        VStack(spacing: 20) {
            ChartPreview(xAxisTitle: nil, yAxisTitle: nil, chartType: .scatterPlot)
                .padding()
            
            ChartPreview(xAxisTitle: "Grind Size", yAxisTitle: "Rating", chartType: .scatterPlot)
                .padding()
        }
    }
}
