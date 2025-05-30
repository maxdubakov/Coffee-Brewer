import SwiftUI
import Charts
import CoreData

struct BarChartView: View {
    let brews: [Brew]
    let xAxis: any ChartAxis
    let yAxis: any ChartAxis
    let color: Color
    let isMinimized: Bool
    var onBarTapped: ((String, Double) -> Void)?
    @State private var animateChart = false
    
    init(brews: [Brew], xAxis: any ChartAxis, yAxis: any ChartAxis, color: Color, isMinimized: Bool = false, onBarTapped: ((String, Double) -> Void)? = nil) {
        self.brews = brews
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.color = color
        self.isMinimized = isMinimized
        self.onBarTapped = onBarTapped
    }
    
    private var aggregatedData: [(category: String, average: Double, count: Int)] {
        // X-axis is categorical, Y-axis is numeric
        let categoryAxis = xAxis
        let numericAxis = yAxis
        
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
            // Chart content
            Charts.Chart(aggregatedData, id: \.category) { item in
                BarMark(
                    x: .value(xAxis.displayName, item.category),
                    y: .value(yAxis.displayName, animateChart ? item.average : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            color,
                            color.opacity(0.7),
                            color.opacity(0.5)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(isMinimized ? 6 : 10)
                .opacity(animateChart ? 1 : 0)
                .annotation(position: .top) {
                    if !isMinimized && animateChart {
                        VStack(spacing: 2) {
                            Text(String(format: "%.1f", item.average))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(BrewerColors.textPrimary)
                            
                            if item.count > 1 {
                                Text("n=\(item.count)")
                                    .font(.system(size: 10))
                                    .foregroundColor(BrewerColors.textSecondary)
                            }
                        }
                    }
                }
            }
            .chartXAxis {
                if !isMinimized {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let text = value.as(String.self) {
                                Text(text)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textPrimary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: 80)
                                    .padding(.top, 8)
                            }
                        }
                        AxisGridLine()
                            .foregroundStyle(BrewerColors.chartGrid)
                    }
                }
            }
            .chartXAxisLabel(alignment: .center) {
                if !isMinimized {
                    Text(xAxis.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(BrewerColors.textSecondary)
                        .padding(.top, 16)
                }
            }
            .chartYAxis {
                if !isMinimized {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel(anchor: .trailing) {
                            if let number = value.as(Double.self) {
                                Text(String(format: "%.1f", number))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary)
                                    .padding(.trailing, 8)
                            }
                        }
                        AxisGridLine()
                            .foregroundStyle(BrewerColors.chartGrid)
                    }
                }
            }
            .chartYAxisLabel(position: .leading) {
                if !isMinimized {
                    Text(yAxis.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(BrewerColors.textSecondary)
                        .rotationEffect(.degrees(180))
                        .padding(.top, 10)
                }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.clear)
            }
            .chartBackground { _ in
                if !aggregatedData.isEmpty && onBarTapped != nil {
                    GeometryReader { geometry in
                        ForEach(aggregatedData.indices, id: \.self) { index in
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .frame(width: geometry.size.width / CGFloat(visibleBarCount))
                                .position(
                                    x: (CGFloat(index) + 0.5) * geometry.size.width / CGFloat(visibleBarCount),
                                    y: geometry.size.height / 2
                                )
                                .onTapGesture {
                                    let item = aggregatedData[index]
                                    onBarTapped?(item.category, item.average)
                                    
                                    // Haptic feedback
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                }
                        }
                    }
                }
            }
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: visibleBarCount)
            .frame(minHeight: isMinimized ? 100 : 350)
            .padding(.horizontal, isMinimized ? 0 : 0)
            .padding(.vertical, isMinimized ? 0 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(0.1)) {
                    animateChart = true
                }
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
                    // Minimized version
                    Text("Minimized Bar Chart")
                        .font(.headline)
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    BarChartView(
                        brews: brews,
                        xAxis: CategoricalAxis(type: .roasterName),
                        yAxis: NumericAxis(type: .rating),
                        color: BrewerColors.espresso,
                        isMinimized: true
                    )
                    
                    // Maximized version
                    Text("Maximized Bar Chart")
                        .font(.headline)
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    BarChartView(
                        brews: brews,
                        xAxis: CategoricalAxis(type: .roasterName),
                        yAxis: NumericAxis(type: .rating),
                        color: BrewerColors.espresso,
                        isMinimized: false
                    )
                }
                .onAppear {
                    let context = PersistenceController.preview.container.viewContext
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
                .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
