import Foundation
import CoreData

struct RecipeFormData {
    var name: String = "New Recipe"
    var roaster: Roaster? = nil
    var grinder: Grinder? = nil
    var temperature: Double = 95.0
    var grindSize: Int16 = 40
    var grams: Int16 = 18
    var ratio: Double = 16.0
    var waterAmount: Int16 = 288
    
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
    }
    
    init(selectedRoaster: Roaster?) {
        self.roaster = selectedRoaster
    }
}