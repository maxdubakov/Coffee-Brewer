import Foundation

struct StageFormData: Identifiable, Hashable, Equatable {
    let id = UUID()
    var type: StageType = .fast
    var seconds: Int16 = 15
    var waterAmount: Int16 = 0
    var orderIndex: Int16 = 0
    
    init() {}
    
    init(from stage: Stage) {
        self.type = StageType.fromString(stage.type ?? "fast") ?? .fast
        self.seconds = stage.seconds
        self.waterAmount = stage.waterAmount
        self.orderIndex = stage.orderIndex
    }
}
