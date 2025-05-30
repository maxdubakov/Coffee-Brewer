import SwiftUI

struct ChartSelectorView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let editingChart: Chart?
    
    @State private var selectedXAxis: AxisConfiguration?
    @State private var selectedYAxis: AxisConfiguration?
    @State private var chartTitle: String = ""
    @State private var selectedColor: String? = nil
    @State private var focusedField: FocusedField?
    
    init(viewModel: HistoryViewModel, editingChart: Chart? = nil) {
        self.viewModel = viewModel
        self.editingChart = editingChart
    }
    
    // Fetch brews for chart preview
    @FetchRequest(
        entity: Brew.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Brew.date, ascending: false)],
        animation: .default
    ) private var brews: FetchedResults<Brew>
    
    private let allAxes: [(String, [any ChartAxis])] = [
        ("Numeric", NumericAxis.allAxes),
        ("Categorical", CategoricalAxis.allAxes),
        ("Temporal", TemporalAxis.allAxes)
    ]
    
    private let xAxisOnlyAxes: [(String, [any ChartAxis])] = [
        ("Categorical", CategoricalAxis.allAxes),
        ("Temporal", TemporalAxis.allAxes)
    ]
    
    private var canCreateChart: Bool {
        selectedXAxis != nil && selectedYAxis != nil && selectedXAxis?.axisId != selectedYAxis?.axisId
    }
    
    private var isEditingMode: Bool {
        editingChart != nil
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
                        
                        Text(isEditingMode ? "Edit Chart" : "Add Chart")
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
                                
                                // Chart Title Field (standalone, custom styling)
                                FormTitleField(
                                    placeholder: "Enter Chart Title",
                                    text: $chartTitle
                                )
                                .padding(.horizontal, 20)
                                
                                // Chart preview widget styled like FlexibleChartWidget
                                VStack(spacing: 0) {
                                    ChartPreview(
                                        xAxisConfiguration: selectedXAxis,
                                        yAxisConfiguration: selectedYAxis,
                                        chartType: currentChartType,
                                        brews: Array(brews),
                                        color: selectedColor?.toColor() ?? BrewerColors.chartPrimary
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
                                        title: "X-Axis (Horizontal)",
                                        field: .name,
                                        axes: xAxisOnlyAxes,
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
                                    
                                    FormColorPickerField(
                                        title: "Chart Color",
                                        selectedColor: $selectedColor
                                    )
                                }
                            }
                        }
                    } actions: {
                        StandardButton(
                            title: isEditingMode ? "Update Chart" : "Save Chart",
                            action: isEditingMode ? updateChart : createChart,
                            style: .primary
                        )
                        .disabled(!canCreateChart)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            initializeForEditing()
        }
    }
    
    private func initializeForEditing() {
        guard let chart = editingChart, let configuration = chart.toChartConfiguration() else { return }
        
        // Set the current chart values
        selectedXAxis = configuration.xAxis
        selectedYAxis = configuration.yAxis
        chartTitle = configuration.title
        selectedColor = configuration.color
    }
    
    private func updateChartTitle() {
        if chartTitle.isEmpty {
            chartTitle = suggestedTitle
        }
    }
    
    private func createChart() {
        guard let xAxis = selectedXAxis, let yAxis = selectedYAxis else { return }
        
        let title = chartTitle.isEmpty ? suggestedTitle : chartTitle
        
        var configuration = ChartConfiguration(
            xAxis: xAxis,
            yAxis: yAxis,
            title: title
        )
        configuration.color = selectedColor
        
        viewModel.addChart(configuration: configuration)
        
        dismiss()
    }
    
    private func updateChart() {
        guard let chart = editingChart,
              let xAxis = selectedXAxis,
              let yAxis = selectedYAxis else { return }
        
        let title = chartTitle.isEmpty ? suggestedTitle : chartTitle
        
        viewModel.updateChart(chart, xAxis: xAxis, yAxis: yAxis, title: title)
        viewModel.updateChartColor(chart, color: selectedColor)
        viewModel.selectedChart = nil // Clear selection
        
        dismiss()
    }
}

#Preview {
    ChartSelectorView(viewModel: HistoryViewModel())
}
