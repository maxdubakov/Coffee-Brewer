import Foundation

extension Grinder {
    var typeIcon: String {
        (type?.lowercased() ?? "").contains("manual") ? "hand.raised" : 
        (type?.lowercased() ?? "").contains("electric") ? "bolt" : 
        "questionmark"
    }
}
