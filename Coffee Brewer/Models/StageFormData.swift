import Foundation

struct StageFormData: Identifiable, Hashable, Equatable {
    let id = UUID()
    var type: StageType = .fast
    var waterAmount: Int16 = 0
    var orderIndex: Int16 = 0
    
    init() {}
    
    init(type: StageType, waterAmount: Int16, orderIndex: Int16) {
        self.type = type
        self.waterAmount = waterAmount
        self.orderIndex = orderIndex
    }
    
    init(from stage: Stage) {
        self.type = StageType.fromString(stage.type ?? "fast") ?? .fast
        self.waterAmount = stage.waterAmount
        self.orderIndex = stage.orderIndex
    }
}
