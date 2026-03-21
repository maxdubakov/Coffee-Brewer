import XCTest
import CoreData
@testable import Coffee_Brewer

@MainActor
final class BrewExtensionsTests: XCTestCase {
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
    
    // MARK: - stagesArray
    
    func testStagesArrayReturnsSortedByOrderIndex() {
        let brew = createTestBrew()
        
        // Add stages out of order
        let stage3 = createStage(brew: brew, type: "fast", water: 100, order: 2)
        let stage1 = createStage(brew: brew, type: "fast", water: 50, order: 0)
        let stage2 = createStage(brew: brew, type: "slow", water: 200, order: 1)
        
        let sorted = brew.stagesArray
        
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].orderIndex, 0)
        XCTAssertEqual(sorted[1].orderIndex, 1)
        XCTAssertEqual(sorted[2].orderIndex, 2)
        XCTAssertEqual(sorted[0].waterAmount, 50)
        XCTAssertEqual(sorted[1].waterAmount, 200)
        XCTAssertEqual(sorted[2].waterAmount, 100)
    }
    
    func testStagesArrayEmptyWhenNoStages() {
        let brew = createTestBrew()
        XCTAssertTrue(brew.stagesArray.isEmpty)
    }
    
    // MARK: - totalStageWater
    
    func testTotalStageWaterSumsAllStages() {
        let brew = createTestBrew()
        _ = createStage(brew: brew, type: "fast", water: 60, order: 0)
        _ = createStage(brew: brew, type: "slow", water: 240, order: 1)
        
        XCTAssertEqual(brew.totalStageWater, 300)
    }
    
    func testTotalStageWaterZeroWhenNoStages() {
        let brew = createTestBrew()
        XCTAssertEqual(brew.totalStageWater, 0)
    }
    
    // MARK: - brewMethodEnum
    
    func testBrewMethodEnumParsesV60() {
        let brew = createTestBrew()
        brew.brewMethod = "V60"
        XCTAssertEqual(brew.brewMethodEnum, .v60)
    }
    
    func testBrewMethodEnumParsesOreaV4() {
        let brew = createTestBrew()
        brew.brewMethod = "Orea V4"
        XCTAssertEqual(brew.brewMethodEnum, .oreaV4)
    }
    
    func testBrewMethodEnumDefaultsToV60ForUnknown() {
        let brew = createTestBrew()
        brew.brewMethod = "Unknown"
        XCTAssertEqual(brew.brewMethodEnum, .v60)
    }
    
    func testBrewMethodEnumDefaultsToV60ForNil() {
        let brew = createTestBrew()
        brew.brewMethod = nil
        XCTAssertEqual(brew.brewMethodEnum, .v60)
    }
    
    // MARK: - coffeeName / coffeeRoasterName
    
    func testCoffeeNameReturnsCoffeeName() {
        let brew = createTestBrew()
        let coffee = Coffee(context: context)
        coffee.name = "Yirgacheffe"
        brew.coffee = coffee
        
        XCTAssertEqual(brew.coffeeName, "Yirgacheffe")
    }
    
    func testCoffeeNameReturnsUnknownWhenNoCoffee() {
        let brew = createTestBrew()
        XCTAssertEqual(brew.coffeeName, "Unknown Coffee")
    }
    
    func testCoffeeRoasterNameReturnsCoffeeRoasterName() {
        let brew = createTestBrew()
        let roaster = Roaster(context: context)
        roaster.name = "Bright Bean"
        let coffee = Coffee(context: context)
        coffee.name = "Test"
        coffee.roaster = roaster
        brew.coffee = coffee
        
        XCTAssertEqual(brew.coffeeRoasterName, "Bright Bean")
    }
    
    func testCoffeeRoasterNameFallsBackToRoasterName() {
        let brew = createTestBrew()
        brew.roasterName = "Fallback Roaster"
        
        XCTAssertEqual(brew.coffeeRoasterName, "Fallback Roaster")
    }
    
    func testCoffeeRoasterNameReturnsUnknownWhenNone() {
        let brew = createTestBrew()
        XCTAssertEqual(brew.coffeeRoasterName, "Unknown Roaster")
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
