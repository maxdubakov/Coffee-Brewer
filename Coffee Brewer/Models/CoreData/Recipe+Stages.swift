import CoreData

extension Recipe {
    var stagesArray: [Stage] {
        let set = stages as? Set<Stage> ?? []
        return set.sorted {
            $0.orderIndex < $1.orderIndex
        }
    }
    
    func addStage(type: String, waterAmount: Int16, seconds: Int16, context: NSManagedObjectContext) {
        let stage = Stage(context: context)
        stage.id = UUID()
        stage.type = type
        stage.waterAmount = waterAmount
        stage.seconds = seconds
        stage.orderIndex = Int16((stages?.count ?? 0))
        stage.recipe = self
    }
    
    func createDefaultStage(context: NSManagedObjectContext) {
        // Add default first stage if no stages exist
        if stagesArray.isEmpty {
            addStage(type: "fast", waterAmount: 100, seconds: 20, context: context)
        }
    }
    
    func totalStageWaterToStep(stepIndex: Int) -> Int16 {
        return stagesArray.prefix(stepIndex + 1).reduce(0) { $0 + $1.waterAmount }
    }
    
    var totalStageWater: Int16 {
        stagesArray.reduce(0) { $0 + $1.waterAmount }
    }
    
    var isStageWaterBalanced: Bool {
        totalStageWater == waterAmount
    }
}
