import SwiftUI
import CoreData

struct FlexibleChartWidget: View {
    @Binding var configuration: ChartConfiguration
    let brews: [Brew]
    let onRemove: () -> Void
    let onConfigure: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(configuration.title)
                    .font(.headline)
                    .foregroundColor(BrewerColors.textPrimary)
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Configure button
                    Button(action: onConfigure) {
                        Image(systemName: "gear")
                            .foregroundColor(BrewerColors.textSecondary)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Expand/Collapse button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            configuration.isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: configuration.isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(BrewerColors.textSecondary)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Remove button
                    Button(action: onRemove) {
                        Image(systemName: "xmark")
                            .foregroundColor(BrewerColors.textSecondary)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(BrewerColors.cardBackground)
            
            if configuration.isExpanded {
                CustomDivider()
                
                // Chart content
                chartView
                    .transition(.asymmetric(
                        insertion: .push(from: .top).combined(with: .opacity),
                        removal: .push(from: .bottom).combined(with: .opacity)
                    ))
            }
        }
        .background(BrewerColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var chartView: some View {
        if let xAxis = configuration.xAxis.createAxis(),
           let yAxis = configuration.yAxis.createAxis() {
            switch configuration.chartType {
            case .scatterPlot:
                ScatterPlotChart(brews: brews, xAxis: xAxis, yAxis: yAxis)
            case .barChart:
                BarChartView(brews: brews, xAxis: xAxis, yAxis: yAxis)
            case .timeSeries:
                TimeSeriesChart(brews: brews, xAxis: xAxis, yAxis: yAxis)
            }
        } else {
            Text("Unable to load chart")
                .foregroundColor(BrewerColors.textSecondary)
                .padding()
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var configuration = ChartConfiguration(
            xAxis: AxisConfiguration(from: TemporalAxis(type: .brewDate)),
            yAxis: AxisConfiguration(from: NumericAxis(type: .rating)),
            title: "Rating Over Time"
        )
        @State private var brews: [Brew] = []
        
        var body: some View {
            GlobalBackground {
                ScrollView {
                    FlexibleChartWidget(
                        configuration: $configuration,
                        brews: brews,
                        onRemove: {
                            print("Remove widget")
                        },
                        onConfigure: {
                            print("Configure widget")
                        }
                    )
                }
                .onAppear {
                    let context = PersistenceController.preview.container.viewContext
                    
                    for i in 0..<30 {
                        let brew = Brew(context: context)
                        brew.id = UUID()
                        brew.date = Date().addingTimeInterval(TimeInterval(-i * 86400))
                        brew.rating = Int16.random(in: 2...5)
                        brew.recipeName = "Test Recipe \(i)"
                        brew.roasterName = ["Blue Bottle", "Stumptown", "Intelligentsia"].randomElement()!
                        brews.append(brew)
                    }
                }
            }
        }
    }
    
    return PreviewWrapper()
}