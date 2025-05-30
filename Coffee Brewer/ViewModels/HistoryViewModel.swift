import SwiftUI
import CoreData
import Combine

class HistoryViewModel: ObservableObject {
    @Published var charts: [Chart] = []
    @Published var showAddChartSheet = false
    @Published var selectedChart: Chart?
    
    private let context: NSManagedObjectContext
    private let userDefaults = UserDefaults.standard
    private let hasLoadedDefaultChartsKey = "hasLoadedDefaultCharts"
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadCharts()
        loadDefaultChartsIfNeeded()
    }
    
    // MARK: - Chart Management
    
    private func loadCharts() {
        charts = Chart.fetchAllCharts(in: context)
    }
    
    private func loadDefaultChartsIfNeeded() {
        // Only load default charts once on first launch
        guard !userDefaults.bool(forKey: hasLoadedDefaultChartsKey) else { return }
        
        let defaultConfigurations = ChartResolver.recommendedConfigurations()
        
        for config in defaultConfigurations {
            _ = Chart(
                xAxis: config.xAxis,
                yAxis: config.yAxis,
                title: config.title,
                context: context
            )
        }
        
        saveContext()
        userDefaults.set(true, forKey: hasLoadedDefaultChartsKey)
        loadCharts()
    }
    
    func addChart(xAxis: AxisConfiguration, yAxis: AxisConfiguration, title: String) {
        _ = Chart(
            xAxis: xAxis,
            yAxis: yAxis,
            title: title,
            context: context
        )
        
        saveContext()
        loadCharts()
    }
    
    func addChart(configuration: ChartConfiguration) {
        _ = Chart(
            xAxis: configuration.xAxis,
            yAxis: configuration.yAxis,
            title: configuration.title,
            context: context
        )
        
        saveContext()
        loadCharts()
    }
    
    func removeChart(_ chart: Chart) {
        chart.archive()
        saveContext()
        loadCharts()
    }
    
    func removeChart(at index: Int) {
        guard index < charts.count else { return }
        let chart = charts[index]
        removeChart(chart)
    }
    
    func updateChart(_ chart: Chart) {
        chart.updateTimestamp()
        saveContext()
        loadCharts()
    }
    
    func updateChart(_ chart: Chart, xAxis: AxisConfiguration, yAxis: AxisConfiguration, title: String) {
        chart.updateConfiguration(xAxis: xAxis, yAxis: yAxis, title: title)
        saveContext()
        loadCharts()
    }
    
    func moveChart(from source: IndexSet, to destination: Int) {
        // Update sort orders based on new positions
        var updatedCharts = charts
        updatedCharts.move(fromOffsets: source, toOffset: destination)
        
        // Assign new sort orders
        for (index, chart) in updatedCharts.enumerated() {
            chart.sortOrder = Int32(updatedCharts.count - index)
        }
        
        saveContext()
        loadCharts()
    }
    
    func toggleExpanded(for chart: Chart) {
        chart.toggleExpanded()
        saveContext()
        // No need to reload charts for UI state changes
        objectWillChange.send()
    }
    
    func updateChartTitle(_ chart: Chart, title: String) {
        chart.updateTitle(title)
        saveContext()
        loadCharts()
    }
    
    func updateChartColor(_ chart: Chart, color: String?) {
        chart.updateColor(color)
        saveContext()
        loadCharts()
    }
    
    func updateChartNotes(_ chart: Chart, notes: String?) {
        chart.updateNotes(notes)
        saveContext()
        loadCharts()
    }
    
    // MARK: - Archive Management
    
    func getArchivedCharts() -> [Chart] {
        return Chart.fetchArchivedCharts(in: context)
    }
    
    func restoreChart(_ chart: Chart) {
        chart.unarchive()
        saveContext()
        loadCharts()
    }
    
    func permanentlyDeleteChart(_ chart: Chart) {
        context.delete(chart)
        saveContext()
    }
    
    // MARK: - Core Data Management
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Compatibility Methods (for existing code)
    
    /// Legacy compatibility - converts charts to ChartConfiguration
    var chartConfigurations: [ChartConfiguration] {
        return charts.compactMap { $0.toChartConfiguration() }
    }
    
    /// Legacy compatibility
    var selectedConfiguration: ChartConfiguration? {
        get {
            selectedChart?.toChartConfiguration()
        }
        set {
            if let config = newValue {
                selectedChart = charts.first { $0.id?.uuidString == config.id.uuidString }
            } else {
                selectedChart = nil
            }
        }
    }
    
    /// Legacy compatibility
    func updateChart(_ configuration: ChartConfiguration) {
        if let chart = charts.first(where: { $0.id?.uuidString == configuration.id.uuidString }) {
            chart.isExpanded = configuration.isExpanded
            updateChart(chart)
        }
    }
    
    /// Legacy compatibility
    func toggleExpanded(for configuration: ChartConfiguration) {
        if let chart = charts.first(where: { $0.id?.uuidString == configuration.id.uuidString }) {
            toggleExpanded(for: chart)
        }
    }
}
