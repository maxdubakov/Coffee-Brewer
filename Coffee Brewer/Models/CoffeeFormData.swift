import Foundation
import CoreData

struct CoffeeFormData: Equatable, Hashable {
    var name: String = ""
    var process: String = ""
    var notes: String = ""
    var roaster: Roaster? = nil
    var country: Country? = nil
    
    init() {}
    
    init(from coffee: Coffee) {
        self.name = coffee.name ?? ""
        self.process = coffee.process ?? ""
        self.notes = coffee.notes ?? ""
        self.roaster = coffee.roaster
        self.country = coffee.country
    }
    
    // MARK: - Equatable
    static func == (lhs: CoffeeFormData, rhs: CoffeeFormData) -> Bool {
        lhs.name == rhs.name &&
        lhs.process == rhs.process &&
        lhs.notes == rhs.notes &&
        lhs.roaster?.objectID == rhs.roaster?.objectID &&
        lhs.country?.objectID == rhs.country?.objectID
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(process)
        hasher.combine(notes)
        hasher.combine(roaster?.objectID)
        hasher.combine(country?.objectID)
    }
}
