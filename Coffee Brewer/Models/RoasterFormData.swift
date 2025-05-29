import Foundation

struct RoasterFormData {
    var name: String = ""
    var country: Country?
    var website: String = ""
    var notes: String = ""
    var foundedYear: String = ""
    
    var websiteURL: URL? {
        guard !website.isEmpty else { return nil }
        
        var urlString = website.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://\(urlString)"
        }
        
        return URL(string: urlString)
    }
    
    var foundedYearInt: Int? {
        guard !foundedYear.isEmpty else { return nil }
        return Int(foundedYear)
    }
    
    init() {
        // Default initializer - keeps existing behavior
    }
    
    init(from roaster: Roaster) {
        self.name = roaster.name ?? ""
        self.country = roaster.country
        self.website = roaster.website ?? ""
        self.notes = roaster.notes ?? ""
        self.foundedYear = roaster.foundedYear > 0 ? String(roaster.foundedYear) : ""
    }
}

extension RoasterFormData: Equatable {
    static func == (lhs: RoasterFormData, rhs: RoasterFormData) -> Bool {
        return lhs.name == rhs.name &&
               lhs.country == rhs.country &&
               lhs.website == rhs.website &&
               lhs.notes == rhs.notes &&
               lhs.foundedYear == rhs.foundedYear
    }
}
