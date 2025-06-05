import Foundation
import CoreData

@MainActor
class DataManager: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var isExporting = false
    @Published var isImporting = false
    @Published var exportError: Error?
    @Published var importError: Error?
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    // MARK: - Export
    func exportData() async throws -> (data: Data, fileName: String) {
        isExporting = true
        defer { isExporting = false }
        let exportData = try await buildExportData()
        let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        let fileName = "CoffeeBrewerBackup_\(dateString).json"
        return (jsonData, fileName)
    }
    
    private func buildExportData() async throws -> [String: Any] {
        let recipesRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let brewsRequest: NSFetchRequest<Brew> = Brew.fetchRequest()
        let roastersRequest: NSFetchRequest<Roaster> = Roaster.fetchRequest()
        let grindersRequest: NSFetchRequest<Grinder> = Grinder.fetchRequest()
        let chartsRequest: NSFetchRequest<Chart> = Chart.fetchRequest()
        
        let recipes = try viewContext.fetch(recipesRequest)
        let brews = try viewContext.fetch(brewsRequest)
        let roasters = try viewContext.fetch(roastersRequest)
        let grinders = try viewContext.fetch(grindersRequest)
        let charts = try viewContext.fetch(chartsRequest)
        
        return [
            "version": "1.0",
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "data": [
                "recipes": recipes.map { $0.export() },
                "brews": brews.map { $0.export() },
                "roasters": roasters.map { $0.export() },
                "grinders": grinders.map { $0.export() },
                "charts": charts.map { $0.export() }
            ]
        ]
    }
    
    // MARK: - Import
    
    func importData(from url: URL) async throws {
        isImporting = true
        defer { isImporting = false }

        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let json = json,
              let version = json["version"] as? String,
              version == "1.0" else {
            throw DataImportError.invalidFormat
        }
        
        guard let dataDict = json["data"] as? [String: Any] else {
            throw DataImportError.missingData
        }
        
        try await importDataFromDictionary(dataDict)
    }
    
    private func importDataFromDictionary(_ data: [String: Any]) async throws {
        // TODO: Implement actual import logic
        // This would involve:
        // 1. Parsing the data
        // 2. Creating Core Data objects
        // 3. Handling duplicates
        // 4. Saving the context
        
        print("Import data: \(data)")
    }
    
    // MARK: - Statistics
    
    func getTotalDataSize() -> Int {
        let recipesRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let brewsRequest: NSFetchRequest<Brew> = Brew.fetchRequest()
        let roastersRequest: NSFetchRequest<Roaster> = Roaster.fetchRequest()
        let grindersRequest: NSFetchRequest<Grinder> = Grinder.fetchRequest()
        let chartsRequest: NSFetchRequest<Chart> = Chart.fetchRequest()
        
        do {
            let recipesCount = try viewContext.count(for: recipesRequest)
            let brewsCount = try viewContext.count(for: brewsRequest)
            let roastersCount = try viewContext.count(for: roastersRequest)
            let grindersCount = try viewContext.count(for: grindersRequest)
            let chartsCount = try viewContext.count(for: chartsRequest)
            
            return recipesCount + brewsCount + roastersCount + grindersCount + chartsCount
        } catch {
            return 0
        }
    }
}

enum DataImportError: LocalizedError {
    case invalidFormat
    case missingData
    case incompatibleVersion
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "The selected file is not a valid Coffee Brewer backup"
        case .missingData:
            return "The backup file is missing required data"
        case .incompatibleVersion:
            return "This backup file version is not supported"
        }
    }
}
