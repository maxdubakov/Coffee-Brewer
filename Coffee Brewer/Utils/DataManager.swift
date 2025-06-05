import Foundation
import CoreData

@MainActor
class DataManager: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var isExporting = false
    @Published var isImporting = false
    
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
    
    func importData(from url: URL) async throws -> ImportResult {
        isImporting = true
        defer { isImporting = false }

        do {
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                throw DataImportError.accessDenied
            }
            
            defer {
                // Stop accessing the security-scoped resource when done
                url.stopAccessingSecurityScopedResource()
            }
            
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
            
            let (imported, ignored) = try await importDataFromDictionary(dataDict)
            return ImportResult.success(imported: imported, ignored: ignored)
        } catch {
            return ImportResult.failure(error: error)
        }
    }
    
    private func importDataFromDictionary(_ data: [String: Any]) async throws -> (imported: [String: Int], ignored: [String: Int]) {
        var counter = ImportCounter()
        
        // Import roasters (no dependencies)
        if let roasters = data["roasters"] as? [[String: Any]] {
            for roasterData in roasters {
                if try Roaster.importFromData(roasterData, context: viewContext) {
                    counter.incrementImported("Roasters")
                } else {
                    counter.incrementIgnored("Roasters")
                }
            }
        }
        
        // Import grinders (no dependencies)
        if let grinders = data["grinders"] as? [[String: Any]] {
            for grinderData in grinders {
                if try Grinder.importFromData(grinderData, context: viewContext) {
                    counter.incrementImported("Grinders")
                } else {
                    counter.incrementIgnored("Grinders")
                }
            }
        }
        
        // Import recipes (depends on roasters and grinders)
        if let recipes = data["recipes"] as? [[String: Any]] {
            for recipeData in recipes {
                if try Recipe.importFromData(recipeData, context: viewContext) {
                    counter.incrementImported("Recipes")
                } else {
                    counter.incrementIgnored("Recipes")
                }
            }
        }
        
        // Import brews (depends on recipes)
        if let brews = data["brews"] as? [[String: Any]] {
            for brewData in brews {
                if try Brew.importFromData(brewData, context: viewContext) {
                    counter.incrementImported("Brews")
                } else {
                    counter.incrementIgnored("Brews")
                }
            }
        }
        
        // Import charts (no dependencies)
        if let charts = data["charts"] as? [[String: Any]] {
            for chartData in charts {
                if try Chart.importFromData(chartData, context: viewContext) {
                    counter.incrementImported("Charts")
                } else {
                    counter.incrementIgnored("Charts")
                }
            }
        }
        
        try viewContext.save()
        
        return counter.result()
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
    case accessDenied
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "The selected file is not a valid Coffee Brewer backup"
        case .missingData:
            return "The backup file is missing required data"
        case .incompatibleVersion:
            return "This backup file version is not supported"
        case .accessDenied:
            return "Permission denied to access the selected file"
        }
    }
}
