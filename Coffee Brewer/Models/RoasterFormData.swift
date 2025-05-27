import Foundation

struct RoasterFormData {
    var name: String = ""
    var location: String = ""
    var website: String = ""
    var notes: String = ""
    var foundedYear: String = ""
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
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
}