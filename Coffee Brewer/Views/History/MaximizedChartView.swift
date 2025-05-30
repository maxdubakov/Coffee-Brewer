import SwiftUI
import CoreData

struct MaximizedChartView: View {
    let chart: Chart
    let brews: [Brew]
    @Environment(\.dismiss) private var dismiss
    
    private var chartConfiguration: ChartConfiguration? {
        chart.toChartConfiguration()
    }
    
    var body: some View {
        NavigationView {
            GlobalBackground {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Button("Back") {
                            dismiss()
                        }
                        .foregroundColor(BrewerColors.textSecondary)
                        
                        Spacer()
                        
                        Text(chart.title ?? "Chart")
                            .font(.headline)
                            .foregroundColor(BrewerColors.textPrimary)
                        
                        Spacer()
                        
                        Text("Back")
                            .foregroundColor(.clear)
                    }
                    .padding()
                    
                    CustomDivider()
                    
                    // Chart Content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Chart Title
                            Text(chart.title ?? "Chart")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(BrewerColors.textPrimary)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            // Maximized Chart
                            if let configuration = chartConfiguration {
                                Group {
                                    switch configuration.chartType {
                                    case .barChart:
                                        BarChartView(
                                            brews: brews,
                                            xAxis: configuration.xAxis.createAxis()!,
                                            yAxis: configuration.yAxis.createAxis()!,
                                            color: configuration.color?.toColor() ?? BrewerColors.chartPrimary,
                                            isMinimized: false
                                        )
                                    case .timeSeries:
                                        TimeSeriesChart(
                                            brews: brews,
                                            xAxis: configuration.xAxis.createAxis()!,
                                            yAxis: configuration.yAxis.createAxis()!,
                                            color: configuration.color?.toColor() ?? BrewerColors.chartPrimary,
                                            isMinimized: false
                                        )
                                    case .scatterPlot:
                                        ScatterPlotChart(
                                            brews: brews,
                                            xAxis: configuration.xAxis.createAxis()!,
                                            yAxis: configuration.yAxis.createAxis()!,
                                            color: configuration.color?.toColor() ?? BrewerColors.chartPrimary
                                        )
                                    }
                                }
                                .background(BrewerColors.cardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                .padding(.horizontal)
                            }
                            
                            // Chart Info Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Chart Details")
                                    .font(.headline)
                                    .foregroundColor(BrewerColors.textPrimary)
                                
                                if let config = chartConfiguration {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text("X-Axis:")
                                                .fontWeight(.medium)
                                                .foregroundColor(BrewerColors.textSecondary)
                                            Text(config.xAxis.displayName)
                                                .foregroundColor(BrewerColors.textPrimary)
                                        }
                                        
                                        HStack {
                                            Text("Y-Axis:")
                                                .fontWeight(.medium)
                                                .foregroundColor(BrewerColors.textSecondary)
                                            Text(config.yAxis.displayName)
                                                .foregroundColor(BrewerColors.textPrimary)
                                        }
                                        
                                        HStack {
                                            Text("Chart Type:")
                                                .fontWeight(.medium)
                                                .foregroundColor(BrewerColors.textSecondary)
                                            Text(config.chartType.rawValue.capitalized)
                                                .foregroundColor(BrewerColors.textPrimary)
                                        }
                                        
                                        HStack {
                                            Text("Data Points:")
                                                .fontWeight(.medium)
                                                .foregroundColor(BrewerColors.textSecondary)
                                            Text("\(brews.count) brews")
                                                .foregroundColor(BrewerColors.textPrimary)
                                        }
                                    }
                                    .font(.subheadline)
                                }
                            }
                            .padding()
                            .background(BrewerColors.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            // Add extra space at bottom for safe area
                            Spacer().frame(height: 100)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var brews: [Brew] = []
        
        var body: some View {
            let context = PersistenceController.preview.container.viewContext
            let chart = Chart(
                xAxis: AxisConfiguration(from: CategoricalAxis(type: .roasterName)),
                yAxis: AxisConfiguration(from: NumericAxis(type: .rating)),
                title: "Rating by Roaster",
                context: context
            )
            
            MaximizedChartView(chart: chart, brews: brews)
                .onAppear {
                    let roasters = ["Blue Bottle Co.", "Stumptown", "Intelligentsia", "Local Roaster"]
                    
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
    
    return PreviewWrapper()
}