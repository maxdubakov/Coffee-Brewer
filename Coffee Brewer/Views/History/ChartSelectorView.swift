import SwiftUI

struct ChartSelectorView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedXAxis: AxisConfiguration?
    @State private var selectedYAxis: AxisConfiguration?
    @State private var chartTitle: String = ""
    
    private let allAxes: [(String, [any ChartAxis])] = [
        ("Numeric", NumericAxis.allAxes),
        ("Categorical", CategoricalAxis.allAxes),
        ("Temporal", TemporalAxis.allAxes)
    ]
    
    private var canCreateChart: Bool {
        selectedXAxis != nil && selectedYAxis != nil && selectedXAxis?.axisId != selectedYAxis?.axisId
    }
    
    private var suggestedTitle: String {
        guard let xAxis = selectedXAxis, let yAxis = selectedYAxis else { return "" }
        return "\(yAxis.displayName) by \(xAxis.displayName)"
    }
    
    var body: some View {
        NavigationView {
            GlobalBackground {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(BrewerColors.textSecondary)
                        
                        Spacer()
                        
                        Text("Add Chart")
                            .font(.headline)
                            .foregroundColor(BrewerColors.textPrimary)
                        
                        Spacer()
                        
                        Button("Add") {
                            createChart()
                        }
                        .foregroundColor(canCreateChart ? BrewerColors.chartPrimary : BrewerColors.textSecondary.opacity(0.5))
                        .disabled(!canCreateChart)
                    }
                    .padding()
                    
                    CustomDivider()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // X-Axis Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("X-AXIS (HORIZONTAL)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(BrewerColors.textPrimary)
                                    .tracking(1.5)
                                
                                ForEach(allAxes, id: \.0) { groupName, axes in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(groupName)
                                            .font(.caption2)
                                            .foregroundColor(BrewerColors.textSecondary)
                                        
                                        ForEach(axes, id: \.id) { axis in
                                            AxisSelectionRow(
                                                axis: axis,
                                                isSelected: selectedXAxis?.axisId == axis.id,
                                                action: {
                                                    selectedXAxis = AxisConfiguration(from: axis)
                                                    updateChartTitle()
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            CustomDivider()
                            
                            // Y-Axis Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Y-AXIS (VERTICAL)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(BrewerColors.textPrimary)
                                    .tracking(1.5)
                                
                                ForEach(allAxes, id: \.0) { groupName, axes in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(groupName)
                                            .font(.caption2)
                                            .foregroundColor(BrewerColors.textSecondary)
                                        
                                        ForEach(axes, id: \.id) { axis in
                                            AxisSelectionRow(
                                                axis: axis,
                                                isSelected: selectedYAxis?.axisId == axis.id,
                                                isDisabled: selectedXAxis?.axisId == axis.id,
                                                action: {
                                                    selectedYAxis = AxisConfiguration(from: axis)
                                                    updateChartTitle()
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            CustomDivider()
                            
                            // Chart Title
                            VStack(alignment: .leading, spacing: 12) {
                                Text("CHART TITLE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(BrewerColors.textPrimary)
                                    .tracking(1.5)
                                
                                TextField("Chart Title", text: $chartTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .foregroundColor(BrewerColors.textPrimary)
                            }
                            .padding(.horizontal)
                            
                            // Preview
                            if let xAxis = selectedXAxis, let yAxis = selectedYAxis {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("PREVIEW")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(BrewerColors.textPrimary)
                                        .tracking(1.5)
                                        .padding(.horizontal)
                                    
                                    let chartType = ChartResolver.resolveChartType(
                                        xAxisType: xAxis.axisType,
                                        yAxisType: yAxis.axisType
                                    )
                                    
                                    HStack {
                                        Image(systemName: iconForChartType(chartType))
                                            .font(.title2)
                                            .foregroundColor(BrewerColors.chartPrimary)
                                        
                                        Text(nameForChartType(chartType))
                                            .font(.headline)
                                            .foregroundColor(BrewerColors.textPrimary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(BrewerColors.surface)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func updateChartTitle() {
        if chartTitle.isEmpty {
            chartTitle = suggestedTitle
        }
    }
    
    private func createChart() {
        guard let xAxis = selectedXAxis, let yAxis = selectedYAxis else { return }
        
        let configuration = ChartConfiguration(
            xAxis: xAxis,
            yAxis: yAxis,
            title: chartTitle.isEmpty ? suggestedTitle : chartTitle
        )
        
        viewModel.addChart(configuration: configuration)
        dismiss()
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
    
    private func nameForChartType(_ type: ChartType) -> String {
        switch type {
        case .scatterPlot:
            return "Scatter Plot"
        case .barChart:
            return "Bar Chart"
        case .timeSeries:
            return "Time Series"
        }
    }
}

struct AxisSelectionRow: View {
    let axis: any ChartAxis
    let isSelected: Bool
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(axis.displayName)
                    .font(.system(size: 16))
                    .foregroundColor(isDisabled ? BrewerColors.textSecondary.opacity(0.3) : BrewerColors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(BrewerColors.chartPrimary)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? BrewerColors.chartPrimary.opacity(0.1) : BrewerColors.surface)
            )
        }
        .disabled(isDisabled)
    }
}

#Preview {
    ChartSelectorView(viewModel: HistoryViewModel())
}