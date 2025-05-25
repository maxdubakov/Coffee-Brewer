import XCTest
import CoreData
@testable import Coffee_Brewer

@MainActor
final class AddRecipeViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        context = PersistenceController.preview.container.viewContext
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }
    
    func testNewRecipeInitialization() {
        // Given
        let roaster = createTestRoaster()
        
        // When
        let viewModel = AddRecipeViewModel(
            selectedRoaster: roaster,
            context: context,
            existingRecipe: nil
        )
        
        // Then
        XCTAssertFalse(viewModel.isEditing)
        XCTAssertEqual(viewModel.formData.name, "New Recipe")
        XCTAssertEqual(viewModel.formData.roaster, roaster)
        XCTAssertNil(viewModel.formData.grinder)
        XCTAssertEqual(viewModel.formData.temperature, 95.0)
        XCTAssertEqual(viewModel.formData.grindSize, 40)
    }
    
    func testEditRecipeInitialization() {
        // Given
        let existingRecipe = createTestRecipe()
        
        // When
        let viewModel = AddRecipeViewModel(
            selectedRoaster: nil,
            context: context,
            existingRecipe: existingRecipe
        )
        
        // Then
        XCTAssertTrue(viewModel.isEditing)
        XCTAssertEqual(viewModel.formData.name, existingRecipe.name)
        XCTAssertEqual(viewModel.formData.roaster, existingRecipe.roaster)
        XCTAssertEqual(viewModel.formData.grinder, existingRecipe.grinder)
        XCTAssertEqual(viewModel.formData.temperature, existingRecipe.temperature)
        XCTAssertEqual(viewModel.formData.grindSize, existingRecipe.grindSize)
    }
    
    func testSaveRecipeCreatesNewRecipe() throws {
        // Given
        let roaster = createTestRoaster()
        let viewModel = AddRecipeViewModel(
            selectedRoaster: roaster,
            context: context,
            existingRecipe: nil
        )
        
        // Modify form data
        viewModel.formData.name = "Test Recipe"
        viewModel.formData.temperature = 93.0
        
        // When
        let savedRecipe = try viewModel.saveRecipe()
        
        // Then
        XCTAssertNotNil(savedRecipe)
        XCTAssertEqual(savedRecipe.name, "Test Recipe")
        XCTAssertEqual(savedRecipe.roaster, roaster)
        XCTAssertEqual(savedRecipe.temperature, 93.0)
    }
    
    func testNoPrematuredCoreDataObjectCreation() {
        // Given
        let initialCount = try! context.count(for: Recipe.fetchRequest())
        
        // When
        let viewModel = AddRecipeViewModel(
            selectedRoaster: nil,
            context: context,
            existingRecipe: nil
        )
        
        // Modify form without saving
        viewModel.formData.name = "Unsaved Recipe"
        viewModel.formData.temperature = 92.0
        
        // Then - No recipe should be created until save
        let currentCount = try! context.count(for: Recipe.fetchRequest())
        XCTAssertEqual(initialCount, currentCount)
    }
    
    // MARK: - Helper Methods
    
    private func createTestRoaster() -> Roaster {
        let roaster = Roaster(context: context)
        roaster.id = UUID()
        roaster.name = "Test Roaster"
        return roaster
    }
    
    private func createTestRecipe() -> Recipe {
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.name = "Existing Recipe"
        recipe.roaster = createTestRoaster()
        recipe.temperature = 94.0
        recipe.grindSize = 35
        recipe.grams = 20
        recipe.ratio = 15.0
        recipe.waterAmount = 300
        return recipe
    }
}