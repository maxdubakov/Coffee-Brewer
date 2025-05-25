import XCTest
import CoreData
@testable import Coffee_Brewer

@MainActor
final class RecipeFormDataTests: XCTestCase {
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = PersistenceController.preview.container.viewContext
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }
    
    func testRecipeFormDataInitialization() {
        // Given
        let formData = RecipeFormData()
        
        // Then
        XCTAssertEqual(formData.name, "New Recipe")
        XCTAssertNil(formData.roaster)
        XCTAssertNil(formData.grinder)
        XCTAssertEqual(formData.temperature, 95.0)
        XCTAssertEqual(formData.grindSize, 40)
        XCTAssertEqual(formData.grams, 18)
        XCTAssertEqual(formData.ratio, 16.0)
        XCTAssertEqual(formData.waterAmount, 288)
        XCTAssertTrue(formData.stages.isEmpty)
    }
    
    func testRecipeFormDataFromExistingRecipe() {
        // Given
        let recipe = createTestRecipe()
        let stage1 = createTestStage(recipe: recipe, type: "fast", water: 36, seconds: 15, order: 0)
        let stage2 = createTestStage(recipe: recipe, type: "wait", water: 0, seconds: 30, order: 1)
        
        // When
        let formData = RecipeFormData(from: recipe)
        
        // Then
        XCTAssertEqual(formData.name, recipe.name)
        XCTAssertEqual(formData.roaster, recipe.roaster)
        XCTAssertEqual(formData.temperature, recipe.temperature)
        XCTAssertEqual(formData.stages.count, 2)
        XCTAssertEqual(formData.stages[0].type.id, "fast")
        XCTAssertEqual(formData.stages[0].waterAmount, 36)
        XCTAssertEqual(formData.stages[1].type.id, "wait")
        XCTAssertEqual(formData.stages[1].waterAmount, 0)
    }
    
    func testStageWaterCalculations() {
        // Given
        var formData = RecipeFormData()
        formData.waterAmount = 300
        
        var stage1 = StageFormData()
        stage1.waterAmount = 50
        
        var stage2 = StageFormData()
        stage2.waterAmount = 250
        
        // When
        formData.stages = [stage1, stage2]
        
        // Then
        XCTAssertEqual(formData.totalStageWater, 300)
        XCTAssertTrue(formData.isStageWaterBalanced)
        
        // When water is not balanced
        formData.stages[1].waterAmount = 200
        
        // Then
        XCTAssertEqual(formData.totalStageWater, 250)
        XCTAssertFalse(formData.isStageWaterBalanced)
    }
    
    func testStagesManagementWithFormData() {
        // Given
        var formData = RecipeFormData()
        formData.name = "Test Recipe"
        formData.waterAmount = 300
        
        let brewMath = BrewMathViewModel(grams: 18, ratio: 16.0, water: 300)
        let viewModel = StagesManagementViewModel(
            formData: formData,
            brewMath: brewMath,
            context: context,
            existingRecipeID: nil
        )
        
        // When - should have default bloom stage
        XCTAssertEqual(viewModel.stages.count, 1)
        XCTAssertEqual(viewModel.stages[0].type.id, "fast")
        XCTAssertEqual(viewModel.stages[0].waterAmount, 36) // 18g * 2
        
        // When adding a new stage
        var newStage = StageFormData()
        newStage.type = .slow
        newStage.waterAmount = 100
        newStage.seconds = 30
        viewModel.addStage(newStage)
        
        // Then
        XCTAssertEqual(viewModel.stages.count, 2)
        XCTAssertEqual(viewModel.stages[1].type.id, "slow")
        XCTAssertEqual(viewModel.stages[1].waterAmount, 100)
        XCTAssertEqual(viewModel.currentWater, 136)
    }
    
    // MARK: - Helper Methods
    
    private func createTestRecipe() -> Recipe {
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.name = "Test Recipe"
        recipe.temperature = 94.0
        recipe.grindSize = 35
        recipe.grams = 18
        recipe.ratio = 16.0
        recipe.waterAmount = 288
        
        let roaster = Roaster(context: context)
        roaster.id = UUID()
        roaster.name = "Test Roaster"
        recipe.roaster = roaster
        
        return recipe
    }
    
    private func createTestStage(recipe: Recipe, type: String, water: Int16, seconds: Int16, order: Int16) -> Stage {
        let stage = Stage(context: context)
        stage.id = UUID()
        stage.type = type
        stage.waterAmount = water
        stage.seconds = seconds
        stage.orderIndex = order
        stage.recipe = recipe
        return stage
    }
}