import Foundation
import CoreData

extension Chart {
    
    // MARK: - Convenience Initializers
    
    convenience init(
        xAxis: AxisConfiguration,
        yAxis: AxisConfiguration,
        title: String,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isExpanded = true
        self.isArchived = false
        
        // X-Axis properties
        self.xAxisType = xAxis.axisType.rawValue
        self.xAxisId = xAxis.axisId
        self.xAxisDisplayName = xAxis.displayName
        
        // Y-Axis properties
        self.yAxisType = yAxis.axisType.rawValue
        self.yAxisId = yAxis.axisId
        self.yAxisDisplayName = yAxis.displayName
        
        // Chart type based on axis types
        self.chartType = ChartResolver.resolveChartType(
            xAxisType: xAxis.axisType,
            yAxisType: yAxis.axisType
        ).rawValue
        
        // Set sort order to current timestamp for newest-first ordering
        self.sortOrder = Int32(Date().timeIntervalSince1970)
    }
    
    // MARK: - Computed Properties
    
    var xAxisConfiguration: AxisConfiguration? {
        guard let xAxisType = self.xAxisType,
              let xAxisId = self.xAxisId,
              let xAxisDisplayName = self.xAxisDisplayName,
              let axisType = AxisType(rawValue: xAxisType) else {
            return nil
        }
        
        return AxisConfiguration(
            axisType: axisType,
            axisId: xAxisId,
            displayName: xAxisDisplayName
        )
    }
    
    var yAxisConfiguration: AxisConfiguration? {
        guard let yAxisType = self.yAxisType,
              let yAxisId = self.yAxisId,
              let yAxisDisplayName = self.yAxisDisplayName,
              let axisType = AxisType(rawValue: yAxisType) else {
            return nil
        }
        
        return AxisConfiguration(
            axisType: axisType,
            axisId: yAxisId,
            displayName: yAxisDisplayName
        )
    }
    
    var resolvedChartType: ChartType {
        guard let chartTypeString = self.chartType,
              let chartType = ChartType(rawValue: chartTypeString) else {
            return .scatterPlot // Default fallback
        }
        return chartType
    }
    
    var xAxis: (any ChartAxis)? {
        return xAxisConfiguration?.createAxis()
    }
    
    var yAxis: (any ChartAxis)? {
        return yAxisConfiguration?.createAxis()
    }
    
    // MARK: - Convenience Methods
    
    func updateTimestamp() {
        self.updatedAt = Date()
    }
    
    func archive() {
        self.isArchived = true
        updateTimestamp()
    }
    
    func unarchive() {
        self.isArchived = false
        updateTimestamp()
    }
    
    func toggleExpanded() {
        self.isExpanded.toggle()
        updateTimestamp()
    }
    
    func updateTitle(_ newTitle: String) {
        self.title = newTitle
        updateTimestamp()
    }
    
    func updateColor(_ newColor: String?) {
        self.color = newColor
        updateTimestamp()
    }
    
    func updateNotes(_ newNotes: String?) {
        self.notes = newNotes
        updateTimestamp()
    }
    
    func updateSortOrder(_ newOrder: Int32) {
        self.sortOrder = newOrder
        updateTimestamp()
    }
    
    func updateConfiguration(xAxis: AxisConfiguration, yAxis: AxisConfiguration, title: String) {
        self.title = title
        
        // Update X-Axis properties
        self.xAxisType = xAxis.axisType.rawValue
        self.xAxisId = xAxis.axisId
        self.xAxisDisplayName = xAxis.displayName
        
        // Update Y-Axis properties
        self.yAxisType = yAxis.axisType.rawValue
        self.yAxisId = yAxis.axisId
        self.yAxisDisplayName = yAxis.displayName
        
        // Update chart type based on new axis types
        self.chartType = ChartResolver.resolveChartType(
            xAxisType: xAxis.axisType,
            yAxisType: yAxis.axisType
        ).rawValue
        
        updateTimestamp()
    }
    
    // MARK: - Chart Configuration Compatibility
    
    /// Creates a ChartConfiguration from this Chart entity for compatibility with existing code
    func toChartConfiguration() -> ChartConfiguration? {
        guard let xAxisConfig = xAxisConfiguration,
              let yAxisConfig = yAxisConfiguration,
              let title = self.title else {
            return nil
        }
        
        var config = ChartConfiguration(
            xAxis: xAxisConfig,
            yAxis: yAxisConfig,
            title: title
        )
        
        config.isExpanded = self.isExpanded
        
        return config
    }
    
    // MARK: - Static Methods
    
    static func fetchAllCharts(in context: NSManagedObjectContext) -> [Chart] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == NO")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Chart.sortOrder, ascending: false)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching charts: \(error)")
            return []
        }
    }
    
    static func fetchArchivedCharts(in context: NSManagedObjectContext) -> [Chart] {
        let request = fetchRequest()
        request.predicate = NSPredicate(format: "isArchived == YES")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Chart.updatedAt, ascending: false)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching archived charts: \(error)")
            return []
        }
    }
}

// MARK: - AxisConfiguration Extension

extension AxisConfiguration {
    init(axisType: AxisType, axisId: String, displayName: String) {
        self.axisType = axisType
        self.axisId = axisId
        self.displayName = displayName
    }
}

// MARK: - ChartType Extension

extension ChartType: CaseIterable {
    public static var allCases: [ChartType] {
        return [.scatterPlot, .barChart, .timeSeries]
    }
}