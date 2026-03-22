import Foundation

enum BrewMethod: String, CaseIterable, Codable {
    case v60 = "V60"
    case oreaV4 = "Orea V4"
    
    // Display name for UI
    var displayName: String {
        return self.rawValue
    }
    
    // Icon name for this brew method
    var iconName: String {
        switch self {
        case .v60:
            return "v60.icon"
        case .oreaV4:
            return "orea.v4"
        }
    }
    
    // Image name for this brew method
    var imageName: String {
        switch self {
        case .v60:
            return "V60"
        case .oreaV4:
            return "Orea"
        }
    }
    
    // Default parameters for each brew method
    var defaultGrams: Int16 {
        return 18
    }
    
    var defaultRatio: Double {
        return 17.0
    }
    
    var defaultTemperature: Double {
        return 96.0
    }
    
    // Initialize from string (for CoreData compatibility)
    init(from string: String) {
        self = BrewMethod(rawValue: string) ?? .v60
    }
}
