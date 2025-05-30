import SwiftUI

struct ChartSelectorView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedXAxis: AxisConfiguration?
    @State private var selectedYAxis: AxisConfiguration?
    @State private var chartTitle: String = ""
    @State private var focusedField: FocusedField?
    
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
    
    private var currentChartType: ChartType {
        guard let xAxis = selectedXAxis, let yAxis = selectedYAxis else {
            return .scatterPlot // Default
        }
        return ChartResolver.resolveChartType(
            xAxisType: xAxis.axisType,
            yAxisType: yAxis.axisType
        )
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
                        
                        Text("Cancel")
                            .foregroundColor(.clear)
                    }
                    .padding()
                    
                    CustomDivider()
                    
                    FixedBottomLayout(
                        contentPadding: EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
                    ) {
                        VStack(alignment: .leading, spacing: 30) {
                            // Chart Preview Section
                            VStack(alignment: .leading, spacing: 18) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chart.xyaxis.line")
                                        .foregroundColor(BrewerColors.caramel)
                                        .font(.system(size: 16))
                                    
                                    SecondaryHeader(title: "Chart Preview")
                                }
                                .padding(.horizontal, 20)
                                
                                // Chart preview widget styled like FlexibleChartWidget
                                VStack(spacing: 0) {
                                    ChartPreview(
                                        xAxisTitle: selectedXAxis?.displayName,
                                        yAxisTitle: selectedYAxis?.displayName,
                                        chartType: currentChartType
                                    )
                                }
                                .background(BrewerColors.cardBackground)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                .padding(.horizontal)
                            }
                            
                            // Axis Selection Section
                            VStack(alignment: .leading, spacing: 18) {
                                FormGroup {
                                    FormAxisPickerField(
                                        title: "X",
                                        field: .name,
                                        axes: allAxes,
                                        selection: $selectedXAxis,
                                        focusedField: $focusedField,
                                        disabledAxisId: nil
                                    )
                                    .onChange(of: selectedXAxis) { _, _ in
                                        updateChartTitle()
                                    }
                                    
                                    Divider()
                                    
                                    FormAxisPickerField(
                                        title: "Y-Axis (Vertical)",
                                        field: .waterml,
                                        axes: allAxes,
                                        selection: $selectedYAxis,
                                        focusedField: $focusedField,
                                        disabledAxisId: selectedXAxis?.axisId
                                    )
                                    .onChange(of: selectedYAxis) { _, _ in
                                        updateChartTitle()
                                    }
                                    
                                    Divider()
                                    
                                    FormKeyboardInputField(
                                        title: "Chart Title",
                                        field: .notes,
                                        keyboardType: .default,
                                        valueToString: { $0 },
                                        stringToValue: { $0 },
                                        value: $chartTitle,
                                        focusedField: $focusedField
                                    )
                                }
                            }
                        }
                    } actions: {
                        StandardButton(
                            title: "Save Chart",
                            action: createChart,
                            style: .primary
                        )
                        .disabled(!canCreateChart)
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
        
        let title = chartTitle.isEmpty ? suggestedTitle : chartTitle
        
        viewModel.addChart(
            xAxis: xAxis,
            yAxis: yAxis,
            title: title
        )
        
        dismiss()
    }
}

#Preview {
    ChartSelectorView(viewModel: HistoryViewModel())
}
