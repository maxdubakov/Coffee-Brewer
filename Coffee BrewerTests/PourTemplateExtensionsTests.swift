import XCTest
import CoreData
@testable import Coffee_Brewer

@MainActor
final class PourTemplateExtensionsTests: XCTestCase {
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
    
    func testStagesArraySortedByOrderIndex() {
        let template = createTemplate(name: "Test", brewMethod: "V60")
        
        // Add out of order
        _ = createTemplateStage(template: template, type: "fast", pct: 40.0, order: 2)
        _ = createTemplateStage(template: template, type: "fast", pct: 20.0, order: 0)
        _ = createTemplateStage(template: template, type: "slow", pct: 40.0, order: 1)
        
        let sorted = template.stagesArray
        
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].orderIndex, 0)
        XCTAssertEqual(sorted[0].waterPercentage, 20.0)
        XCTAssertEqual(sorted[1].orderIndex, 1)
        XCTAssertEqual(sorted[1].type, "slow")
        XCTAssertEqual(sorted[2].orderIndex, 2)
        XCTAssertEqual(sorted[2].waterPercentage, 40.0)
    }
    
    // MARK: - createStages(for:waterAmount:)
    
    func testCreateStagesCalculatesCorrectWaterAmounts() {
        let template = createTemplate(name: "V60 Default", brewMethod: "V60")
        _ = createTemplateStage(template: template, type: "fast", pct: 20.0, order: 0)
        _ = createTemplateStage(template: template, type: "slow", pct: 80.0, order: 1)
        
        let brew = Brew(context: context)
        brew.id = UUID()
        brew.waterAmount = 300
        
        template.createStages(for: brew, waterAmount: 300, context: context)
        
        let stages = brew.stagesArray
        XCTAssertEqual(stages.count, 2)
        XCTAssertEqual(stages[0].type, "fast")
        XCTAssertEqual(stages[0].waterAmount, 60)   // 300 * 20%
        XCTAssertEqual(stages[0].orderIndex, 0)
        XCTAssertEqual(stages[1].type, "slow")
        XCTAssertEqual(stages[1].waterAmount, 240)  // 300 * 80%
        XCTAssertEqual(stages[1].orderIndex, 1)
    }
    
    func testCreateStagesThreeStageTemplate() {
        let template = createTemplate(name: "Orea V4", brewMethod: "Orea V4")
        _ = createTemplateStage(template: template, type: "fast", pct: 20.0, order: 0)
        _ = createTemplateStage(template: template, type: "slow", pct: 40.0, order: 1)
        _ = createTemplateStage(template: template, type: "fast", pct: 40.0, order: 2)
        
        let brew = Brew(context: context)
        brew.id = UUID()
        brew.waterAmount = 300
        
        template.createStages(for: brew, waterAmount: 300, context: context)
        
        let stages = brew.stagesArray
        XCTAssertEqual(stages.count, 3)
        XCTAssertEqual(stages[0].waterAmount, 60)   // 300 * 20%
        XCTAssertEqual(stages[1].waterAmount, 120)  // 300 * 40%
        XCTAssertEqual(stages[2].waterAmount, 120)  // 300 * 40%
    }
    
    func testCreateStagesAssignsBrew() {
        let template = createTemplate(name: "Test", brewMethod: "V60")
        _ = createTemplateStage(template: template, type: "fast", pct: 100.0, order: 0)
        
        let brew = Brew(context: context)
        brew.id = UUID()
        
        template.createStages(for: brew, waterAmount: 250, context: context)
        
        let stages = brew.stagesArray
        XCTAssertEqual(stages.count, 1)
        XCTAssertEqual(stages[0].brew, brew)
    }
    
    // MARK: - seedBuiltInTemplates
    
    func testSeedBuiltInTemplatesCreatesTwo() {
        PourTemplate.seedBuiltInTemplates(in: context)
        
        let request: NSFetchRequest<PourTemplate> = PourTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "isBuiltIn == YES")
        let templates = try! context.fetch(request)
        
        XCTAssertEqual(templates.count, 2)
        
        let names = Set(templates.map { $0.name ?? "" })
        XCTAssertTrue(names.contains("V60 Default"))
        XCTAssertTrue(names.contains("Orea V4 Default"))
    }
    
    func testSeedBuiltInTemplatesIsIdempotent() {
        PourTemplate.seedBuiltInTemplates(in: context)
        PourTemplate.seedBuiltInTemplates(in: context)
        
        let request: NSFetchRequest<PourTemplate> = PourTemplate.fetchRequest()
        request.predicate = NSPredicate(format: "isBuiltIn == YES")
        let templates = try! context.fetch(request)
        
        XCTAssertEqual(templates.count, 2, "Seeding twice should not duplicate templates")
    }
    
    // MARK: - Helpers
    
    private func createTemplate(name: String, brewMethod: String) -> PourTemplate {
        let template = PourTemplate(context: context)
        template.id = UUID()
        template.name = name
        template.brewMethod = brewMethod
        template.isBuiltIn = false
        return template
    }
    
    @discardableResult
    private func createTemplateStage(template: PourTemplate, type: String, pct: Double, order: Int16) -> TemplateStage {
        let stage = TemplateStage(context: context)
        stage.id = UUID()
        stage.type = type
        stage.waterPercentage = pct
        stage.orderIndex = order
        stage.template = template
        return stage
    }
}
