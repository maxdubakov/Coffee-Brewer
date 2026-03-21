import XCTest
import CoreData
@testable import Coffee_Brewer

@MainActor
final class CoffeeFormDataTests: XCTestCase {
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
        let formData = CoffeeFormData()
        
        XCTAssertEqual(formData.name, "")
        XCTAssertEqual(formData.process, "")
        XCTAssertEqual(formData.notes, "")
        XCTAssertNil(formData.roaster)
        XCTAssertNil(formData.country)
    }
    
    // MARK: - init(from:)
    
    func testInitFromCoffeeCopiesAllFields() {
        let roaster = Roaster(context: context)
        roaster.id = UUID()
        roaster.name = "Bright Bean"
        
        let country = Country(context: context)
        country.id = UUID()
        country.name = "Ethiopia"
        country.flag = "🇪🇹"
        
        let coffee = Coffee(context: context)
        coffee.id = UUID()
        coffee.name = "Yirgacheffe Natural"
        coffee.process = "Natural"
        coffee.notes = "Fruity and sweet"
        coffee.roaster = roaster
        coffee.country = country
        
        let formData = CoffeeFormData(from: coffee)
        
        XCTAssertEqual(formData.name, "Yirgacheffe Natural")
        XCTAssertEqual(formData.process, "Natural")
        XCTAssertEqual(formData.notes, "Fruity and sweet")
        XCTAssertEqual(formData.roaster, roaster)
        XCTAssertEqual(formData.country, country)
    }
    
    func testInitFromCoffeeHandlesNilFields() {
        let coffee = Coffee(context: context)
        coffee.id = UUID()
        coffee.name = nil
        coffee.process = nil
        coffee.notes = nil
        
        let formData = CoffeeFormData(from: coffee)
        
        XCTAssertEqual(formData.name, "")
        XCTAssertEqual(formData.process, "")
        XCTAssertEqual(formData.notes, "")
        XCTAssertNil(formData.roaster)
        XCTAssertNil(formData.country)
    }
    
    // MARK: - Equatable
    
    func testEqualFormDataAreEqual() {
        var a = CoffeeFormData()
        a.name = "Test"
        a.process = "Washed"
        
        var b = CoffeeFormData()
        b.name = "Test"
        b.process = "Washed"
        
        XCTAssertEqual(a, b)
    }
    
    func testDifferentNamesAreNotEqual() {
        var a = CoffeeFormData()
        a.name = "Coffee A"
        
        var b = CoffeeFormData()
        b.name = "Coffee B"
        
        XCTAssertNotEqual(a, b)
    }
    
    func testDifferentRoastersAreNotEqual() {
        let roaster1 = Roaster(context: context)
        roaster1.id = UUID()
        roaster1.name = "Roaster 1"
        
        let roaster2 = Roaster(context: context)
        roaster2.id = UUID()
        roaster2.name = "Roaster 2"
        
        var a = CoffeeFormData()
        a.roaster = roaster1
        
        var b = CoffeeFormData()
        b.roaster = roaster2
        
        XCTAssertNotEqual(a, b)
    }
}
