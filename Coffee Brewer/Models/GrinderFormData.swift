import Foundation

struct GrinderFormData {
    var name: String = ""
    var burrType: String = "Conical"
    var burrSize: String = "43"
    var dosingType: String = "Single Dose"
    var type: String = "Manual"
    var settingsFrom: Int16 = 0
    var settingsTo: Int16 = 50
    var settingsStep: Double = 1.0
    
    var burrSizeInt: Int? {
        guard !burrSize.isEmpty else { return nil }
        return Int(burrSize)
    }
    
    init() {
        // Default initializer - keeps existing behavior
    }
    
    init(from grinder: Grinder) {
        self.name = grinder.name ?? ""
        self.burrType = grinder.burrType ?? ""
        self.burrSize = grinder.burrSize > 0 ? String(grinder.burrSize) : ""
        self.dosingType = grinder.dosingType ?? "Single Dose"
        self.type = grinder.type ?? "Manual"
        self.settingsFrom = grinder.from
        self.settingsTo = grinder.to
        self.settingsStep = grinder.step
    }
}

extension GrinderFormData: Equatable {
    static func == (lhs: GrinderFormData, rhs: GrinderFormData) -> Bool {
        return lhs.name == rhs.name &&
               lhs.burrType == rhs.burrType &&
               lhs.burrSize == rhs.burrSize &&
               lhs.dosingType == rhs.dosingType &&
               lhs.type == rhs.type &&
               lhs.settingsFrom == rhs.settingsFrom &&
               lhs.settingsTo == rhs.settingsTo &&
               lhs.settingsStep == rhs.settingsStep
    }
}
