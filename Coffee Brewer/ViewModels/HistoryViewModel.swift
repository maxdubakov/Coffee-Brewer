import SwiftUI
import CoreData
import Combine

class HistoryViewModel: ObservableObject {
    @Published var chartConfigurations: [ChartConfiguration] = []
    @Published var showAddChartSheet = false
    @Published var selectedConfiguration: ChartConfiguration?
    
    private let userDefaults = UserDefaults.standard
    private let chartConfigurationsKey = "historyChartConfigurations"
    
    init() {
        loadChartConfigurations()
    }
    
    private func loadChartConfigurations() {
        if let data = userDefaults.data(forKey: chartConfigurationsKey),
           let configurations = ChartConfiguration.decode(from: data) {
            chartConfigurations = configurations
        } else {
            // Load default configurations on first launch
            chartConfigurations = ChartResolver.recommendedConfigurations()
            saveChartConfigurations()
        }
    }
    
    private func saveChartConfigurations() {
        if let data = ChartConfiguration.encode(chartConfigurations) {
            userDefaults.set(data, forKey: chartConfigurationsKey)
        }
    }
    
    func addChart(configuration: ChartConfiguration) {
        chartConfigurations.append(configuration)
        saveChartConfigurations()
    }
    
    func removeChart(at index: Int) {
        guard index < chartConfigurations.count else { return }
        chartConfigurations.remove(at: index)
        saveChartConfigurations()
    }
    
    func updateChart(_ configuration: ChartConfiguration) {
        if let index = chartConfigurations.firstIndex(where: { $0.id == configuration.id }) {
            chartConfigurations[index] = configuration
            saveChartConfigurations()
        }
    }
    
    func moveChart(from source: IndexSet, to destination: Int) {
        chartConfigurations.move(fromOffsets: source, toOffset: destination)
        saveChartConfigurations()
    }
    
    func toggleExpanded(for configuration: ChartConfiguration) {
        if let index = chartConfigurations.firstIndex(where: { $0.id == configuration.id }) {
            chartConfigurations[index].isExpanded.toggle()
            saveChartConfigurations()
        }
    }
}