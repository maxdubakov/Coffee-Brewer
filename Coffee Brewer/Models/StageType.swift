struct StageType: Identifiable, CustomStringConvertible, Equatable {
    let id: String
    let name: String
    
    var description: String {
        return name
    }
    
    static let fast = StageType(id: "fast", name: "Fast")
    static let slow = StageType(id: "slow", name: "Slow")
    static let wait = StageType(id: "wait", name: "Wait")
    
    static let allTypes: [StageType] = [.fast, .slow, .wait]
    
    static func fromString(_ string: String) -> StageType? {
        return allTypes.first { $0.id.lowercased() == string.lowercased() }
    }
    
    static func == (lhs: StageType, rhs: StageType) -> Bool {
        return lhs.id == rhs.id
    }
}
