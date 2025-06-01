import Foundation
import CoreData

struct RecipeFormData: Equatable, Hashable {
    var name: String = "New Recipe"
    var roaster: Roaster? = nil
    var grinder: Grinder? = nil
    var temperature: Double = 95.0
    var grindSize: Int16 = 40
    var grams: Int16 = 18
    var ratio: Double = 16.0
    var waterAmount: Int16 = 288
    var stages: [StageFormData] = []
    
    init() {}
    
    init(from recipe: Recipe) {
        self.name = recipe.name ?? "New Recipe"
        self.roaster = recipe.roaster
        self.grinder = recipe.grinder
        self.temperature = recipe.temperature
        self.grindSize = recipe.grindSize
        self.grams = recipe.grams
        self.ratio = recipe.ratio
        self.waterAmount = recipe.waterAmount
        self.stages = recipe.stagesArray.map { StageFormData(from: $0) }
    }
    
    init(selectedRoaster: Roaster?, selectedGrinder: Grinder?) {
        self.roaster = selectedRoaster
        self.grinder = selectedGrinder
    }
    
    // MARK: - Computed Properties
    var totalStageWater: Int16 {
        stages.reduce(0) { $0 + $1.waterAmount }
    }
    
    var isStageWaterBalanced: Bool {
        totalStageWater == waterAmount
    }
    
    // MARK: - Equatable
    static func == (lhs: RecipeFormData, rhs: RecipeFormData) -> Bool {
        lhs.name == rhs.name &&
        lhs.roaster?.objectID == rhs.roaster?.objectID &&
        lhs.grinder?.objectID == rhs.grinder?.objectID &&
        lhs.temperature == rhs.temperature &&
        lhs.grindSize == rhs.grindSize &&
        lhs.grams == rhs.grams &&
        lhs.ratio == rhs.ratio &&
        lhs.waterAmount == rhs.waterAmount &&
        lhs.stages == rhs.stages
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(roaster?.objectID)
        hasher.combine(grinder?.objectID)
        hasher.combine(temperature)
        hasher.combine(grindSize)
        hasher.combine(grams)
        hasher.combine(ratio)
        hasher.combine(waterAmount)
        hasher.combine(stages)
    }
}
