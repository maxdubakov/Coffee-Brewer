import Foundation
import CoreData

struct RecipeFormData: Equatable, Hashable {
    var name: String = "New Recipe"
    var roaster: Roaster? = nil
    var grinder: Grinder? = nil
    var brewMethod: BrewMethod = .v60
    var oreaBottomType: OreaBottomType? = nil
    var temperature: Double = 95.0
    var grindSize: Double? = nil
    var grams: Int16 = 18
    var ratio: Double = 16.0
    var waterAmount: Int16 = 288
    var stages: [StageFormData] = []
    
    init() {}
    
    init(from recipe: Recipe) {
        self.name = recipe.name ?? "New Recipe"
        self.roaster = recipe.roaster
        self.grinder = recipe.grinder
        self.brewMethod = BrewMethod(from: recipe.brewMethod ?? "V60")
        if let oreaBottomString = recipe.oreaBottomType {
            self.oreaBottomType = OreaBottomType(rawValue: oreaBottomString)
        }
        self.temperature = recipe.temperature
        self.grindSize = recipe.grindSize > 0 ? Double(recipe.grindSize) : nil
        self.grams = recipe.grams
        self.ratio = recipe.ratio
        self.waterAmount = recipe.waterAmount
        self.stages = recipe.stagesArray.map { StageFormData(from: $0) }
    }
    
    init(selectedRoaster: Roaster?, selectedGrinder: Grinder?, brewMethod: BrewMethod? = nil) {
        self.roaster = selectedRoaster
        self.grinder = selectedGrinder
        if let brewMethod = brewMethod {
            self.brewMethod = brewMethod
            self.temperature = brewMethod.defaultTemperature
            self.grams = brewMethod.defaultGrams
            self.ratio = brewMethod.defaultRatio
            self.waterAmount = Int16(Double(brewMethod.defaultGrams) * brewMethod.defaultRatio)
            
            // Set default bottom type for Orea
            if brewMethod == .oreaV4 {
                self.oreaBottomType = .classic
            }
        }
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
        lhs.brewMethod == rhs.brewMethod &&
        lhs.oreaBottomType == rhs.oreaBottomType &&
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
        hasher.combine(brewMethod)
        hasher.combine(oreaBottomType)
        hasher.combine(temperature)
        hasher.combine(grindSize)
        hasher.combine(grams)
        hasher.combine(ratio)
        hasher.combine(waterAmount)
        hasher.combine(stages)
    }
}
