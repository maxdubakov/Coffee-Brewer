import XCTest
import CoreData
@testable import Coffee_Brewer

@MainActor
final class CoffeeExtensionsTests: XCTestCase {
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
    
    // MARK: - brewsArray
    
    func testBrewsArraySortedNewestFirst() {
        let coffee = createTestCoffee()
        
        let oldDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let midDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let newDate = Date()
        
        _ = createBrew(coffee: coffee, date: oldDate, rating: 3.0)
        _ = createBrew(coffee: coffee, date: newDate, rating: 5.0)
        _ = createBrew(coffee: coffee, date: midDate, rating: 4.0)
        
        let sorted = coffee.brewsArray
        
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].rating, 5.0)  // newest
        XCTAssertEqual(sorted[1].rating, 4.0)  // middle
        XCTAssertEqual(sorted[2].rating, 3.0)  // oldest
    }
    
    func testBrewsArrayEmptyWhenNoBrews() {
        let coffee = createTestCoffee()
        XCTAssertTrue(coffee.brewsArray.isEmpty)
    }
    
    // MARK: - latestBrew
    
    func testLatestBrewReturnsNewest() {
        let coffee = createTestCoffee()
        
        let oldDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        _ = createBrew(coffee: coffee, date: oldDate, rating: 3.0)
        _ = createBrew(coffee: coffee, date: Date(), rating: 5.0)
        
        XCTAssertEqual(coffee.latestBrew?.rating, 5.0)
    }
    
    func testLatestBrewNilWhenNoBrews() {
        let coffee = createTestCoffee()
        XCTAssertNil(coffee.latestBrew)
    }
    
    // MARK: - brewCount
    
    func testBrewCountReturnsCorrectCount() {
        let coffee = createTestCoffee()
        _ = createBrew(coffee: coffee, date: Date(), rating: 3.0)
        _ = createBrew(coffee: coffee, date: Date(), rating: 4.0)
        _ = createBrew(coffee: coffee, date: Date(), rating: 5.0)
        
        XCTAssertEqual(coffee.brewCount, 3)
    }
    
    func testBrewCountZeroWhenNoBrews() {
        let coffee = createTestCoffee()
        XCTAssertEqual(coffee.brewCount, 0)
    }
    
    // MARK: - bestRating
    
    func testBestRatingReturnsHighest() {
        let coffee = createTestCoffee()
        _ = createBrew(coffee: coffee, date: Date(), rating: 2.0)
        _ = createBrew(coffee: coffee, date: Date(), rating: 5.0)
        _ = createBrew(coffee: coffee, date: Date(), rating: 3.0)
        
        XCTAssertEqual(coffee.bestRating, 5.0)
    }
    
    func testBestRatingZeroWhenNoBrews() {
        let coffee = createTestCoffee()
        XCTAssertEqual(coffee.bestRating, 0)
    }
    
    func testBestRatingReturnsFractionalRating() {
        let coffee = createTestCoffee()
        _ = createBrew(coffee: coffee, date: Date(), rating: 3.0)
        _ = createBrew(coffee: coffee, date: Date(), rating: 4.5)
        _ = createBrew(coffee: coffee, date: Date(), rating: 2.0)
        
        XCTAssertEqual(coffee.bestRating, 4.5)
    }
    
    // MARK: - displayName / roasterDisplayName
    
    func testDisplayNameReturnsCoffeeName() {
        let coffee = createTestCoffee()
        coffee.name = "Yirgacheffe Natural"
        XCTAssertEqual(coffee.displayName, "Yirgacheffe Natural")
    }
    
    func testDisplayNameReturnsDefaultWhenNil() {
        let coffee = createTestCoffee()
        coffee.name = nil
        XCTAssertEqual(coffee.displayName, "Untitled Coffee")
    }
    
    func testRoasterDisplayNameReturnsRoasterName() {
        let coffee = createTestCoffee()
        let roaster = Roaster(context: context)
        roaster.name = "Bright Bean"
        coffee.roaster = roaster
        XCTAssertEqual(coffee.roasterDisplayName, "Bright Bean")
    }
    
    func testRoasterDisplayNameReturnsDefaultWhenNoRoaster() {
        let coffee = createTestCoffee()
        XCTAssertEqual(coffee.roasterDisplayName, "Unknown Roaster")
    }
    
    // MARK: - Helpers
    
    private func createTestCoffee() -> Coffee {
        let coffee = Coffee(context: context)
        coffee.id = UUID()
        coffee.name = "Test Coffee"
        coffee.createdAt = Date()
        return coffee
    }
    
    @discardableResult
    private func createBrew(coffee: Coffee, date: Date, rating: Double) -> Brew {
        let brew = Brew(context: context)
        brew.id = UUID()
        brew.coffee = coffee
        brew.date = date
        brew.rating = rating
        brew.brewMethod = "V60"
        brew.grams = 18
        brew.ratio = 16.0
        brew.waterAmount = 288
        brew.temperature = 94.0
        brew.grindSize = 30.0
        return brew
    }
}
