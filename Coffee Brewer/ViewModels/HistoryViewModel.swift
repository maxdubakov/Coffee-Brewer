import SwiftUI
import CoreData

class HistoryViewModel: ObservableObject {
    @Published var charts: [Chart] = []
    @Published var selectedChart: Chart?
    
    private let context: NSManagedObjectContext
    private let userDefaults = UserDefaults.standard
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadCharts()
    }
    
    // MARK: - Chart Management
    
    private func loadCharts() {
        charts = Chart.fetchAllCharts(in: context)
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
        let chart = Chart(
            xAxis: configuration.xAxis,
            yAxis: configuration.yAxis,
            title: configuration.title,
            context: context
        )
        chart.color = configuration.color
        
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
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
}
