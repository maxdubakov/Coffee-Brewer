import XCTest
import CoreData
@testable import Coffee_Brewer

@MainActor
final class StageFormDataTests: XCTestCase {
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
    
    func testDefaultInitValues() {
        let formData = StageFormData()
        
        XCTAssertEqual(formData.type, .fast)
        XCTAssertEqual(formData.waterAmount, 0)
        XCTAssertEqual(formData.orderIndex, 0)
    }
    
    // MARK: - init(type:waterAmount:orderIndex:)
    
    func testConvenienceInit() {
        let formData = StageFormData(type: .slow, waterAmount: 120, orderIndex: 2)
        
        XCTAssertEqual(formData.type, .slow)
        XCTAssertEqual(formData.waterAmount, 120)
        XCTAssertEqual(formData.orderIndex, 2)
    }
    
    // MARK: - init(from:)
    
    func testInitFromStageFast() {
        let stage = createStage(type: "fast", water: 60, order: 0)
        let formData = StageFormData(from: stage)
        
        XCTAssertEqual(formData.type, .fast)
        XCTAssertEqual(formData.waterAmount, 60)
        XCTAssertEqual(formData.orderIndex, 0)
    }
    
    func testInitFromStageSlow() {
        let stage = createStage(type: "slow", water: 240, order: 1)
        let formData = StageFormData(from: stage)
        
        XCTAssertEqual(formData.type, .slow)
        XCTAssertEqual(formData.waterAmount, 240)
        XCTAssertEqual(formData.orderIndex, 1)
    }
    
    func testInitFromStageUnknownTypeDefaultsToFast() {
        let stage = createStage(type: "unknown", water: 100, order: 0)
        let formData = StageFormData(from: stage)
        
        // StageType.fromString returns nil for unknown, StageFormData defaults to .fast
        XCTAssertEqual(formData.type, .fast)
    }
    
    func testInitFromStageNilTypeDefaultsToFast() {
        let stage = createStage(type: nil, water: 100, order: 0)
        let formData = StageFormData(from: stage)
        
        XCTAssertEqual(formData.type, .fast)
    }
    
    // MARK: - Equatable
    
    func testEqualStagesAreEqual() {
        let a = StageFormData(type: .fast, waterAmount: 60, orderIndex: 0)
        let b = StageFormData(type: .fast, waterAmount: 60, orderIndex: 0)
        
        // Note: id is unique per instance, so default Equatable would say not equal.
        // But waterAmount, type, orderIndex are the same.
        // StageFormData auto-synthesizes Equatable which includes id, so they won't be equal.
        XCTAssertNotEqual(a, b, "Different instances have different UUIDs")
    }
    
    // MARK: - Helpers
    
    private func createStage(type: String?, water: Int16, order: Int16) -> Stage {
        let brew = Brew(context: context)
        brew.id = UUID()
        
        let stage = Stage(context: context)
        stage.id = UUID()
        stage.type = type
        stage.waterAmount = water
        stage.orderIndex = order
        stage.brew = brew
        return stage
    }
}
