import SwiftUI
import Charts
import CoreData

struct TimeSeriesChart: View {
    let brews: [Brew]
    let xAxis: any ChartAxis
    let yAxis: any ChartAxis
    let color: Color
    let isMinimized: Bool
    
    init(brews: [Brew], xAxis: any ChartAxis, yAxis: any ChartAxis, color: Color, isMinimized: Bool = false) {
        self.brews = brews
        self.xAxis = xAxis
        self.yAxis = yAxis
        self.color = color
        self.isMinimized = isMinimized
    }
    
    private var timeSeriesData: [(date: Date, value: Double, label: String)] {
        // X-axis is temporal, Y-axis is numeric
        let temporalAxis = xAxis
        let numericAxis = yAxis
        
        guard let temporal = temporalAxis as? TemporalAxis else { return [] }
        
        // Group brews by time period and calculate averages
        var groups: [Date: [Double]] = [:]
        
        for brew in brews {
            if let temporalValue = temporal.extractValue(from: brew) as? TemporalAxisValue,
               let numericValue = numericAxis.extractValue(from: brew) as? NumericAxisValue {
                let groupDate = normalizeDate(temporalValue.date, for: temporal.type)
                groups[groupDate, default: []].append(numericValue.numericValue)
            }
        }
        
        return groups.map { date, values in
            let average = values.reduce(0, +) / Double(values.count)
            return (date: date, value: average, label: temporal.formatDate(date))
        }
        .sorted { $0.date < $1.date }
    }
    
    private func normalizeDate(_ date: Date, for type: TemporalAxisType) -> Date {
        let calendar = Calendar.current
        switch type {
        case .brewDate:
            return calendar.startOfDay(for: date)
        case .brewWeek:
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            return calendar.date(from: components) ?? date
        case .brewMonth:
            let components = calendar.dateComponents([.year, .month], from: date)
            return calendar.date(from: components) ?? date
        case .dayOfWeek, .timeOfDay:
            return date
        }
    }
    
    var body: some View {
        Charts.Chart(timeSeriesData, id: \.date) { item in
            AreaMark(
                x: .value(xAxis.displayName, item.date),
                y: .value(yAxis.displayName, item.value)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        color.opacity(0.5),
                        color.opacity(0.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Main line
            LineMark(
                x: .value(xAxis.displayName, item.date),
                y: .value(yAxis.displayName, item.value)
            )
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .interpolationMethod(.catmullRom)
            
            // Points with subtle shadow (only show in maximized mode)
            if !isMinimized {
                PointMark(
                    x: .value(xAxis.displayName, item.date),
                    y: .value(yAxis.displayName, item.value)
                )
                .foregroundStyle(color)
                .symbolSize(80)
                .symbol {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                        .background(
                            Circle()
                                .fill(color.opacity(0.1))
                                .frame(width: 16, height: 16)
                        )
                }
            }
        }
        .chartXAxis(isMinimized ? .hidden : .visible)
        .chartYAxis(isMinimized ? .hidden : .visible)
        .chartXAxis {
            if !isMinimized {
                AxisMarks { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(formatAxisDate(date))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(BrewerColors.textPrimary)
                        }
                    }
                    AxisGridLine()
                        .foregroundStyle(BrewerColors.chartGrid)
                    AxisTick()
                        .foregroundStyle(BrewerColors.chartGrid)
                }
            }
        }
        .chartYAxis {
            if !isMinimized {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel(anchor: .trailing) {
                        if let number = value.as(Double.self) {
                            Text(formatAxisNumber(number))
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(BrewerColors.textPrimary)
                                .padding(.trailing, 4)
                        }
                    }
                    AxisGridLine()
                        .foregroundStyle(BrewerColors.chartGrid)
                    AxisTick()
                        .foregroundStyle(BrewerColors.chartGrid)
                }
            }
        }
        .frame(minHeight: isMinimized ? 80 : 200, maxHeight: isMinimized ? 120 : 300)
        .padding(isMinimized ? 0 : 16)
    }
    
    private func formatAxisDate(_ date: Date) -> String {
        if let temporal = xAxis as? TemporalAxis {
            return temporal.formatDate(date)
        }
        return ""
    }
    
    private func formatAxisNumber(_ number: Double) -> String {
        if let numeric = yAxis as? NumericAxis {
            return numeric.formatValue(number)
        }
        return String(format: "%.1f", number)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var brews: [Brew] = []
        
        var body: some View {
            GlobalBackground {
                VStack(spacing: 40) {
                    // Minimized version
                    Text("Minimized Time Series Chart")
                        .font(.headline)
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    TimeSeriesChart(
                        brews: brews,
                        xAxis: TemporalAxis(type: .brewDate),
                        yAxis: NumericAxis(type: .rating),
                        color: BrewerColors.chartPrimary,
                        isMinimized: true
                    )
                    
                    // Maximized version
                    Text("Maximized Time Series Chart")
                        .font(.headline)
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    TimeSeriesChart(
                        brews: brews,
                        xAxis: TemporalAxis(type: .brewDate),
                        yAxis: NumericAxis(type: .rating),
                        color: BrewerColors.chartPrimary,
                        isMinimized: false
                    )
                }
                .onAppear {
                    let context = PersistenceController.preview.container.viewContext
                    
                    for i in 0..<30 {
                        let brew = Brew(context: context)
                        brew.id = UUID()
                        brew.date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
                        brew.rating = Int16.random(in: 2...5)
                        brew.recipeName = "Test Recipe \(i)"
                        brew.roasterName = "Blue Bottle"
                        brew.recipeGrindSize = Int16.random(in: 15...25)
                        brew.recipeTemperature = Double.random(in: 92...96)
                        brew.recipeGrams = Int16.random(in: 15...20)
                        brew.recipeWaterAmount = Int16.random(in: 250...300)
                        brew.actualDurationSeconds = Int16.random(in: 180...300)
                        brews.append(brew)
                    }
                }
            }
        }
    }
    
    return PreviewWrapper()
}
