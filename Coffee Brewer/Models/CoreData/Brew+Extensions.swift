import Foundation
import CoreData

extension Brew {
    var stagesArray: [Stage] {
        let set = stages as? Set<Stage> ?? []
        return set.sorted {
            $0.orderIndex < $1.orderIndex
        }
    }
    
    var brewMethodEnum: BrewMethod {
        return BrewMethod(from: self.brewMethod ?? "V60")
    }
    
    var totalStageWater: Int16 {
        stagesArray.reduce(0) { $0 + $1.waterAmount }
    }
    
    var coffeeName: String {
        coffee?.name ?? "Unknown Coffee"
    }
    
    var coffeeRoasterName: String {
        coffee?.roaster?.name ?? roasterName ?? "Unknown Roaster"
    }
}
