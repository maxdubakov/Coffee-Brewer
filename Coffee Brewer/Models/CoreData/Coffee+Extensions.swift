import Foundation
import CoreData

extension Coffee {
    var brewsArray: [Brew] {
        let set = brews as? Set<Brew> ?? []
        return set.sorted {
            ($0.date ?? .distantPast) > ($1.date ?? .distantPast)
        }
    }
    
    var latestBrew: Brew? {
        brewsArray.first
    }
    
    var brewCount: Int {
        brews?.count ?? 0
    }
    
    var bestRating: Int16 {
        brewsArray.map(\.rating).max() ?? 0
    }
    
    var displayName: String {
        name ?? "Untitled Coffee"
    }
    
    var roasterDisplayName: String {
        roaster?.name ?? "Unknown Roaster"
    }
}
