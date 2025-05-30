import SwiftUI
import CoreData

struct ChartDetailView: View {
    @ObservedObject var chart: Chart
    @State private var showEditSheet = false
    @State private var selectedDataPoint: (category: String, value: Double)? = nil
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Brew.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Brew.date, ascending: false)],
        animation: .default
    ) private var brews: FetchedResults<Brew>
    
    private var chartConfiguration: ChartConfiguration? {
        chart.toChartConfiguration()
    }
    
    var body: some View {
        GlobalBackground {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Premium Header Section
                    VStack(alignment: .leading, spacing: 4) {
                        // Title with gradient
                        Text(chart.title ?? "Chart")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(BrewerColors.textPrimary)
                        
                        // Data points as secondary text
                        Text("\(brews.count) data points")
                            .font(.system(size: 13))
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Premium Chart Container
                    if let configuration = chartConfiguration {
                        // Chart content
                        Group {
                            switch configuration.chartType {
                            case .barChart:
                                BarChartView(
                                    brews: Array(brews),
                                    xAxis: configuration.xAxis.createAxis()!,
                                    yAxis: configuration.yAxis.createAxis()!,
                                    color: configuration.color?.toColor() ?? BrewerColors.chartPrimary,
                                    isMinimized: false,
                                    onBarTapped: { category, value in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            if selectedDataPoint?.category == category {
                                                selectedDataPoint = nil
                                            } else {
                                                selectedDataPoint = (category: category, value: value)
                                            }
                                        }
                                    }
                                )
                                .frame(minHeight: 400, maxHeight: 500)
                            case .timeSeries:
                                TimeSeriesChart(
                                    brews: Array(brews),
                                    xAxis: configuration.xAxis.createAxis()!,
                                    yAxis: configuration.yAxis.createAxis()!,
                                    color: configuration.color?.toColor() ?? BrewerColors.chartPrimary,
                                    isMinimized: false
                                )
                                .frame(minHeight: 400, maxHeight: 500)
                            case .scatterPlot:
                                ScatterPlotChart(
                                    brews: Array(brews),
                                    xAxis: configuration.xAxis.createAxis()!,
                                    yAxis: configuration.yAxis.createAxis()!,
                                    color: configuration.color?.toColor() ?? BrewerColors.chartPrimary
                                )
                                .frame(minHeight: 400, maxHeight: 500)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    
                    // Selected data point detail (if applicable)
                    if let dataPoint = selectedDataPoint {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Selected")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary)
                                Spacer()
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(dataPoint.category)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(BrewerColors.cream)
                                    Text("Average Value")
                                        .font(.system(size: 12))
                                        .foregroundColor(BrewerColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Text(String(format: "%.1f", dataPoint.value))
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [BrewerColors.chartPrimary, BrewerColors.caramel],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(BrewerColors.surface.opacity(0.6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(BrewerColors.chartPrimary.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Add extra space at bottom
                    Spacer().frame(height: 100)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14))
                        Text("Edit")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(BrewerColors.chartPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(BrewerColors.chartPrimary.opacity(0.15))
                    )
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            ChartSelectorView(
                viewModel: HistoryViewModel(context: viewContext),
                editingChart: chart
            )
        }
    }
}

// MARK: - Extensions for Axis Configuration
extension AxisConfiguration {
    var shortName: String {
        switch displayName {
        case "Roaster": return "Roaster"
        case "Grinder": return "Grinder"
        case "Recipe": return "Recipe"
        case "Bean Origin": return "Origin"
        case "Rating": return "Rating"
        case "Water Temperature": return "Temp"
        case "Grind Size": return "Grind"
        case "Brew Time": return "Time"
        case "Bean Weight": return "Beans"
        case "Water Amount": return "Water"
        case "Number of Brews": return "Count"
        case "Brew Date": return "Date"
        default: return displayName
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
            
            NavigationStack {
                ChartDetailView(chart: chart)
                    .environment(\.managedObjectContext, context)
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
    }
    
    return PreviewWrapper()
}