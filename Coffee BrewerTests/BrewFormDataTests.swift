import XCTest
import CoreData
@testable import Coffee_Brewer

@MainActor
final class BrewFormDataTests: XCTestCase {
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        let controller = PersistenceController(inMemory: true)
        context = controller.container.viewContext
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }
    
    // MARK: - Default init
    
    func testDefaultInitHasExpectedDefaults() {
        let formData = BrewFormData()
        
        XCTAssertEqual(formData.brewMethod, .v60)
        XCTAssertEqual(formData.grams, 18)
        XCTAssertEqual(formData.ratio, 16.0)
        XCTAssertEqual(formData.waterAmount, 288)
        XCTAssertEqual(formData.temperature, 95.0)
        XCTAssertEqual(formData.grindSize, 0.0)
        XCTAssertTrue(formData.stages.isEmpty)
        XCTAssertEqual(formData.rating, 0)
        XCTAssertFalse(formData.isAssessed)
    }
    
    // MARK: - init(brewMethod:)
    
    func testInitWithV60BrewMethod() {
        let formData = BrewFormData(brewMethod: .v60)
        
        XCTAssertEqual(formData.brewMethod, .v60)
        XCTAssertEqual(formData.grams, 18)
        XCTAssertEqual(formData.ratio, 16.0)
        XCTAssertEqual(formData.waterAmount, 288)  // 18 * 16
        XCTAssertEqual(formData.temperature, 95.0)
    }
    
    func testInitWithOreaBrewMethod() {
        let formData = BrewFormData(brewMethod: .oreaV4)
        
        XCTAssertEqual(formData.brewMethod, .oreaV4)
        XCTAssertEqual(formData.grams, 20)
        XCTAssertEqual(formData.ratio, 15.0)
        XCTAssertEqual(formData.waterAmount, 300)  // 20 * 15
        XCTAssertEqual(formData.temperature, 93.0)
    }
    
    // MARK: - init(cloning:)
    
    func testCloningBrewCopiesAllParameters() {
        let brew = createTestBrew()
        brew.brewMethod = "Orea V4"
        brew.grams = 20
        brew.ratio = 15.0
        brew.waterAmount = 300
        brew.temperature = 93.0
        brew.grindSize = 25.0
        brew.roasterName = "Test Roaster"
        brew.grinderName = "Test Grinder"
        
        // Add stages
        createStage(brew: brew, type: "fast", water: 60, order: 0)
        createStage(brew: brew, type: "slow", water: 240, order: 1)
        
        let cloned = BrewFormData(cloning: brew)
        
        XCTAssertEqual(cloned.brewMethod, .oreaV4)
        XCTAssertEqual(cloned.grams, 20)
        XCTAssertEqual(cloned.ratio, 15.0)
        XCTAssertEqual(cloned.waterAmount, 300)
        XCTAssertEqual(cloned.temperature, 93.0)
        XCTAssertEqual(cloned.grindSize, 25.0)
        XCTAssertEqual(cloned.roasterName, "Test Roaster")
        XCTAssertEqual(cloned.grinderName, "Test Grinder")
        XCTAssertEqual(cloned.stages.count, 2)
        XCTAssertEqual(cloned.stages[0].waterAmount, 60)
        XCTAssertEqual(cloned.stages[1].waterAmount, 240)
    }
    
    func testCloningBrewDoesNotCopyRating() {
        let brew = createTestBrew()
        brew.rating = 5
        brew.acidity = 7
        brew.isAssessed = true
        brew.notes = "Great brew"
        
        let cloned = BrewFormData(cloning: brew)
        
        XCTAssertEqual(cloned.rating, 0)
        XCTAssertEqual(cloned.acidity, 0)
        XCTAssertFalse(cloned.isAssessed)
        XCTAssertEqual(cloned.notes, "")
    }
    
    func testCloningBrewSetsNewDate() {
        let brew = createTestBrew()
        let oldDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        brew.date = oldDate
        
        let cloned = BrewFormData(cloning: brew)
        
        // Cloned date should be now, not the old date
        XCTAssertTrue(cloned.date.timeIntervalSince(oldDate) > 0)
        XCTAssertTrue(cloned.date.timeIntervalSinceNow < 1.0) // within 1 second of now
    }
    
    // MARK: - init(from:)
    
    func testInitFromBrewCopiesEverything() {
        let brew = createTestBrew()
        brew.brewMethod = "V60"
        brew.grams = 18
        brew.ratio = 16.0
        brew.waterAmount = 288
        brew.temperature = 94.0
        brew.grindSize = 30.0
        brew.rating = 4
        brew.acidity = 7
        brew.bitterness = 3
        brew.body = 6
        brew.sweetness = 8
        brew.tds = 1.4
        brew.notes = "Good brew"
        brew.isAssessed = true
        brew.name = "Morning V60"
        brew.roasterName = "Test Roaster"
        brew.grinderName = "Test Grinder"
        
        createStage(brew: brew, type: "fast", water: 58, order: 0)
        createStage(brew: brew, type: "slow", water: 230, order: 1)
        
        let formData = BrewFormData(from: brew)
        
        XCTAssertEqual(formData.brewMethod, .v60)
        XCTAssertEqual(formData.grams, 18)
        XCTAssertEqual(formData.ratio, 16.0)
        XCTAssertEqual(formData.waterAmount, 288)
        XCTAssertEqual(formData.temperature, 94.0)
        XCTAssertEqual(formData.grindSize, 30.0)
        XCTAssertEqual(formData.rating, 4)
        XCTAssertEqual(formData.acidity, 7)
        XCTAssertEqual(formData.bitterness, 3)
        XCTAssertEqual(formData.body, 6)
        XCTAssertEqual(formData.sweetness, 8)
        XCTAssertEqual(formData.tds, 1.4)
        XCTAssertEqual(formData.notes, "Good brew")
        XCTAssertTrue(formData.isAssessed)
        XCTAssertEqual(formData.name, "Morning V60")
        XCTAssertEqual(formData.roasterName, "Test Roaster")
        XCTAssertEqual(formData.grinderName, "Test Grinder")
        XCTAssertEqual(formData.stages.count, 2)
    }
    
    // MARK: - totalStageWater
    
    func testTotalStageWaterSumsCorrectly() {
        var formData = BrewFormData()
        formData.stages = [
            StageFormData(type: .fast, waterAmount: 60, orderIndex: 0),
            StageFormData(type: .slow, waterAmount: 240, orderIndex: 1)
        ]
        
        XCTAssertEqual(formData.totalStageWater, 300)
    }
    
    func testTotalStageWaterZeroWhenEmpty() {
        let formData = BrewFormData()
        XCTAssertEqual(formData.totalStageWater, 0)
    }
    
    // MARK: - Helpers
    
    private func createTestBrew() -> Brew {
        let brew = Brew(context: context)
        brew.id = UUID()
        brew.brewMethod = "V60"
        brew.grams = 18
        brew.ratio = 16.0
        brew.waterAmount = 288
        brew.temperature = 94.0
        brew.grindSize = 30.0
        brew.date = Date()
        return brew
    }
    
    @discardableResult
    private func createStage(brew: Brew, type: String, water: Int16, order: Int16) -> Stage {
        let stage = Stage(context: context)
        stage.id = UUID()
        stage.type = type
        stage.waterAmount = water
        stage.orderIndex = order
        stage.brew = brew
        return stage
    }
}
