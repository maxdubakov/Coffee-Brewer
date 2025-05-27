import Foundation

struct GrinderFormData {
    var name: String = ""
    var burrType: String = ""
    var burrSize: String = ""
    var dosingType: String = "Single Dose"
    var type: String = "Manual"
    
    var burrSizeInt: Int? {
        guard !burrSize.isEmpty else { return nil }
        return Int(burrSize)
    }
}
