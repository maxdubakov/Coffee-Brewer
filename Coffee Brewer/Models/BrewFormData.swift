import Foundation
import CoreData

struct BrewFormData: Equatable, Hashable {
    // Brew parameters (owned directly by brew now)
    var brewMethod: BrewMethod = .v60
    var grams: Int16 = 18
    var ratio: Double = 16.0
    var waterAmount: Int16 = 288
    var temperature: Double = 95.0
    var grindSize: Double = 0.0
    var stages: [StageFormData] = []
    
    // Assessment (filled in later)
    var rating: Int16 = 0
    var acidity: Int16 = 0
    var bitterness: Int16 = 0
    var body: Int16 = 0
    var sweetness: Int16 = 0
    var tds: Double = 0.0
    var notes: String = ""
    var isAssessed: Bool = false
    
    // Metadata
    var name: String = ""
    var date: Date = Date()
    
    // Denormalized names for history display
    var roasterName: String = ""
    var grinderName: String = ""
    
    init() {}
    
    /// Create a new brew form pre-populated from defaults for a brew method
    init(brewMethod: BrewMethod) {
        self.brewMethod = brewMethod
        self.grams = brewMethod.defaultGrams
        self.ratio = brewMethod.defaultRatio
        self.temperature = brewMethod.defaultTemperature
        self.waterAmount = Int16(Double(brewMethod.defaultGrams) * brewMethod.defaultRatio)
    }
    
    /// Clone from a previous brew (the "clone and tweak" pattern)
    init(cloning brew: Brew) {
        self.brewMethod = brew.brewMethodEnum
        self.grams = brew.grams
        self.ratio = brew.ratio
        self.waterAmount = brew.waterAmount
        self.temperature = brew.temperature
        self.grindSize = brew.grindSize
        self.roasterName = brew.roasterName ?? ""
        self.grinderName = brew.grinderName ?? ""
        self.date = Date()
        
        // Clone stages from previous brew
        self.stages = brew.stagesArray.map { StageFormData(from: $0) }
    }
    
    /// Edit an existing brew
    init(from brew: Brew) {
        self.brewMethod = brew.brewMethodEnum
        self.grams = brew.grams
        self.ratio = brew.ratio
        self.waterAmount = brew.waterAmount
        self.temperature = brew.temperature
        self.grindSize = brew.grindSize
        self.rating = brew.rating
        self.acidity = brew.acidity
        self.bitterness = brew.bitterness
        self.body = brew.body
        self.sweetness = brew.sweetness
        self.tds = brew.tds
        self.notes = brew.notes ?? ""
        self.isAssessed = brew.isAssessed
        self.name = brew.name ?? ""
        self.date = brew.date ?? Date()
        self.roasterName = brew.roasterName ?? ""
        self.grinderName = brew.grinderName ?? ""
        self.stages = brew.stagesArray.map { StageFormData(from: $0) }
    }
    
    // MARK: - Computed Properties
    
    var totalStageWater: Int16 {
        stages.reduce(0) { $0 + $1.waterAmount }
    }
    
    // MARK: - Equatable
    static func == (lhs: BrewFormData, rhs: BrewFormData) -> Bool {
        lhs.brewMethod == rhs.brewMethod &&
        lhs.grams == rhs.grams &&
        lhs.ratio == rhs.ratio &&
        lhs.waterAmount == rhs.waterAmount &&
        lhs.temperature == rhs.temperature &&
        lhs.grindSize == rhs.grindSize &&
        lhs.rating == rhs.rating &&
        lhs.acidity == rhs.acidity &&
        lhs.bitterness == rhs.bitterness &&
        lhs.body == rhs.body &&
        lhs.sweetness == rhs.sweetness &&
        lhs.tds == rhs.tds &&
        lhs.notes == rhs.notes &&
        lhs.isAssessed == rhs.isAssessed &&
        lhs.name == rhs.name &&
        lhs.date == rhs.date &&
        lhs.stages == rhs.stages
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(brewMethod)
        hasher.combine(grams)
        hasher.combine(ratio)
        hasher.combine(waterAmount)
        hasher.combine(temperature)
        hasher.combine(grindSize)
        hasher.combine(rating)
        hasher.combine(notes)
        hasher.combine(name)
        hasher.combine(date)
        hasher.combine(stages)
    }
}
