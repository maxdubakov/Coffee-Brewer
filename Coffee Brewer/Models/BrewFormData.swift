import Foundation
import CoreData

struct BrewFormData: Equatable, Hashable {
    var name: String = ""
    var rating: Int16 = 0
    var acidity: Int16 = 0
    var bitterness: Int16 = 0
    var body: Int16 = 0
    var sweetness: Int16 = 0
    var tds: Double = 0.0
    var notes: String = ""
    var date: Date = Date()
    var actualDurationSeconds: Int16 = 0
    
    // Recipe snapshot data for historical preservation
    var recipeName: String = ""
    var recipeGrams: Int16 = 0
    var recipeWaterAmount: Int16 = 0
    var recipeRatio: Double = 0.0
    var recipeTemperature: Double = 0.0
    var recipeGrindSize: Int16 = 0
    var roasterName: String = ""
    var grinderName: String = ""
    
    init() {}
    
    init(recipe: Recipe, actualElapsedTime: Double) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        self.name = "\(recipe.name ?? "Untitled Recipe") - \(dateFormatter.string(from: Date()))"
        self.date = Date()
        self.actualDurationSeconds = Int16(actualElapsedTime)
        
        // Copy recipe data for historical preservation
        self.recipeName = recipe.name ?? ""
        self.recipeGrams = recipe.grams
        self.recipeWaterAmount = recipe.waterAmount
        self.recipeRatio = recipe.ratio
        self.recipeTemperature = recipe.temperature
        self.recipeGrindSize = recipe.grindSize
        self.roasterName = recipe.roaster?.name ?? ""
        self.grinderName = recipe.grinder?.name ?? ""
    }
    
    init(from brew: Brew) {
        self.name = brew.name ?? ""
        self.rating = brew.rating
        self.acidity = brew.acidity
        self.bitterness = brew.bitterness
        self.body = brew.body
        self.sweetness = brew.sweetness
        self.tds = brew.tds
        self.notes = brew.notes ?? ""
        self.date = brew.date ?? Date()
        self.actualDurationSeconds = brew.actualDurationSeconds
        
        self.recipeName = brew.recipeName ?? ""
        self.recipeGrams = brew.recipeGrams
        self.recipeWaterAmount = brew.recipeWaterAmount
        self.recipeRatio = brew.recipeRatio
        self.recipeTemperature = brew.recipeTemperature
        self.recipeGrindSize = brew.recipeGrindSize
        self.roasterName = brew.roasterName ?? ""
        self.grinderName = brew.grinderName ?? ""
    }
    
    // MARK: - Equatable
    static func == (lhs: BrewFormData, rhs: BrewFormData) -> Bool {
        lhs.name == rhs.name &&
        lhs.rating == rhs.rating &&
        lhs.acidity == rhs.acidity &&
        lhs.bitterness == rhs.bitterness &&
        lhs.body == rhs.body &&
        lhs.sweetness == rhs.sweetness &&
        lhs.tds == rhs.tds &&
        lhs.notes == rhs.notes &&
        lhs.date == rhs.date &&
        lhs.actualDurationSeconds == rhs.actualDurationSeconds
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(rating)
        hasher.combine(acidity)
        hasher.combine(bitterness)
        hasher.combine(body)
        hasher.combine(sweetness)
        hasher.combine(tds)
        hasher.combine(notes)
        hasher.combine(date)
        hasher.combine(actualDurationSeconds)
    }
}