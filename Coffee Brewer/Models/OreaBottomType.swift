import Foundation

enum OreaBottomType: String, CaseIterable, Codable, Identifiable, CustomStringConvertible {
    case classic = "Classic"
    case fast = "Fast"
    case open = "Open"
    case apex = "Apex"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .classic:
            return "Balanced extraction"
        case .fast:
            return "Faster flow rate"
        case .open:
            return "Maximum flow"
        case .apex:
            return "Precision control"
        }
    }
}