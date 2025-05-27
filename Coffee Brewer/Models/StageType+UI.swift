import SwiftUI

// MARK: - StageType UI Extensions
extension StageType {
    /// The color associated with this stage type
    var color: Color {
        switch self {
        case .fast, .slow:
            return BrewerColors.caramel
        case .wait:
            return BrewerColors.amber
        default:
            return BrewerColors.coffee
        }
    }
    
    /// The icon name for this stage type
    var icon: String {
        switch self {
        case .fast, .slow:
            return "drop.fill"
        case .wait:
            return "hourglass"
        default:
            return "questionmark.circle"
        }
    }
    
    /// The display name for this stage type
    var displayName: String {
        switch self {
        case .fast:
            return "Fast Pour"
        case .slow:
            return "Slow Pour"
        case .wait:
            return "Wait"
        default:
            return "Unknown Stage"
        }
    }
}

// MARK: - String Extensions for Stage Type
extension String {
    /// Convert string to StageType properties when StageType object is not available
    var stageColor: Color {
        switch self {
        case "fast", "slow":
            return BrewerColors.caramel
        case "wait":
            return BrewerColors.amber
        default:
            return BrewerColors.coffee
        }
    }
    
    var stageIcon: String {
        switch self {
        case "fast", "slow":
            return "drop.fill"
        case "wait":
            return "hourglass"
        default:
            return "questionmark.circle"
        }
    }
    
    var stageDisplayName: String {
        switch self {
        case "fast":
            return "Fast Pour"
        case "slow":
            return "Slow Pour"
        case "wait":
            return "Wait"
        default:
            return "Unknown Stage"
        }
    }
}