import SwiftUI

struct FlexibleChartWidget: View {
    @Binding var configuration: ChartConfiguration
    let brews: [Brew]
    let onRemove: () -> Void
    let onConfigure: () -> Void
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - Tappable to expand/collapse
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
                            .font(.system(size: 18, weight: .light))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Remove button
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(red: 0.9, green: 0.25, blue: 0.25))
                            .font(.system(size: 22, weight: .light))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(BrewerColors.cardBackground)
            .contentShape(Rectangle()) // Make entire header tappable
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    configuration.isExpanded.toggle()
                }
            }
            
            // Animated content container
            VStack(spacing: 0) {
                if configuration.isExpanded {
                    CustomDivider()
                        .transition(.opacity)
                    
                    // Chart content
                    chartView
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                }
            }
            .clipped() // Prevent content from overflowing into title area
            .animation(.easeInOut(duration: 0.3), value: configuration.isExpanded)
        }
        .background(BrewerColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .alert("Delete Chart?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("This chart will be permanently removed from your analytics.")
        }
    }
    
    @ViewBuilder
    private var chartView: some View {
        if let xAxis = configuration.xAxis.createAxis(),
           let yAxis = configuration.yAxis.createAxis() {
            let chartColor = configuration.color?.toColor() ?? BrewerColors.chartPrimary
            
            switch configuration.chartType {
            case .scatterPlot:
                ScatterPlotChart(brews: brews, xAxis: xAxis, yAxis: yAxis, color: chartColor)
            case .barChart:
                BarChartView(brews: brews, xAxis: xAxis, yAxis: yAxis, color: chartColor)
            case .timeSeries:
                TimeSeriesChart(brews: brews, xAxis: xAxis, yAxis: yAxis, color: chartColor)
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
