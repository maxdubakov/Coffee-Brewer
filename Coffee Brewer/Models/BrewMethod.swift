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
    
    // Default parameters for each brew method
    var defaultGrams: Int16 {
        switch self {
        case .v60:
            return 18
        case .oreaV4:
            return 20
        }
    }
    
    var defaultRatio: Double {
        switch self {
        case .v60:
            return 16.0
        case .oreaV4:
            return 15.0
        }
    }
    
    var defaultTemperature: Double {
        switch self {
        case .v60:
            return 95.0
        case .oreaV4:
            return 93.0
        }
    }
    
    // Initialize from string (for CoreData compatibility)
    init(from string: String) {
        self = BrewMethod(rawValue: string) ?? .v60
    }
}