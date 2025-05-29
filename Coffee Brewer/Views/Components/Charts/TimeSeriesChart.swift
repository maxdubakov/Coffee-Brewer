import SwiftUI
import Charts
import CoreData

struct TimeSeriesChart: View {
    let brews: [Brew]
    let xAxis: any ChartAxis
    let yAxis: any ChartAxis
    
    private var timeSeriesData: [(date: Date, value: Double, label: String)] {
        let (temporalAxis, numericAxis) = if xAxis.axisType == .temporal {
            (xAxis, yAxis)
        } else {
            (yAxis, xAxis)
        }
        
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
        Chart(timeSeriesData, id: \.date) { item in
            if xAxis.axisType == .temporal {
                // Area under the line for subtle depth
                AreaMark(
                    x: .value(xAxis.displayName, item.date),
                    y: .value(yAxis.displayName, item.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            BrewerColors.chartPrimary.opacity(0.3),
                            BrewerColors.chartPrimary.opacity(0.05)
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
                .foregroundStyle(BrewerColors.chartPrimary)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
                
                // Points with subtle shadow
                PointMark(
                    x: .value(xAxis.displayName, item.date),
                    y: .value(yAxis.displayName, item.value)
                )
                .foregroundStyle(BrewerColors.chartPrimary)
                .symbolSize(80)
                .symbol {
                    Circle()
                        .fill(BrewerColors.chartPrimary)
                        .frame(width: 8, height: 8)
                        .background(
                            Circle()
                                .fill(BrewerColors.chartPrimary.opacity(0.3))
                                .frame(width: 16, height: 16)
                        )
                }
            } else {
                // Horizontal orientation
                AreaMark(
                    x: .value(xAxis.displayName, item.value),
                    y: .value(yAxis.displayName, item.date)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            BrewerColors.chartPrimary.opacity(0.3),
                            BrewerColors.chartPrimary.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                
                LineMark(
                    x: .value(xAxis.displayName, item.value),
                    y: .value(yAxis.displayName, item.date)
                )
                .foregroundStyle(BrewerColors.chartPrimary)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value(xAxis.displayName, item.value),
                    y: .value(yAxis.displayName, item.date)
                )
                .foregroundStyle(BrewerColors.chartPrimary)
                .symbolSize(80)
                .symbol {
                    Circle()
                        .fill(BrewerColors.chartPrimary)
                        .frame(width: 8, height: 8)
                        .background(
                            Circle()
                                .fill(BrewerColors.chartPrimary.opacity(0.3))
                                .frame(width: 16, height: 16)
                        )
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
                    if xAxis.axisType == .temporal, let date = value.as(Date.self) {
                        Text(formatAxisDate(date))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(BrewerColors.textSecondary)
                    } else if xAxis.axisType == .numeric, let number = value.as(Double.self) {
                        Text(formatAxisNumber(number))
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
                    if yAxis.axisType == .temporal, let date = value.as(Date.self) {
                        Text(formatAxisDate(date))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(BrewerColors.textSecondary)
                            .padding(.trailing, 4)
                    } else if yAxis.axisType == .numeric, let number = value.as(Double.self) {
                        Text(formatAxisNumber(number))
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
    
    private func formatAxisDate(_ date: Date) -> String {
        if let temporal = xAxis as? TemporalAxis {
            return temporal.formatDate(date)
        } else if let temporal = yAxis as? TemporalAxis {
            return temporal.formatDate(date)
        }
        return ""
    }
    
    private func formatAxisNumber(_ number: Double) -> String {
        // Format based on which axis is being formatted
        if xAxis.axisType == .numeric, let numeric = xAxis as? NumericAxis {
            return numeric.formatValue(number)
        } else if yAxis.axisType == .numeric, let numeric = yAxis as? NumericAxis {
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
                TimeSeriesChart(
                    brews: brews,
                    xAxis: TemporalAxis(type: .brewDate),
                    yAxis: NumericAxis(type: .rating)
                )
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
