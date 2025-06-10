import Foundation

extension Grinder {
    var typeIcon: String {
        (type?.lowercased() ?? "").contains("manual") ? "manual" :
        (type?.lowercased() ?? "").contains("electric") ? "electric" : 
        "questionmark"
    }
}
