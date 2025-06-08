import Foundation
import CoreData

extension Recipe {
    var brewMethodEnum: BrewMethod {
        return BrewMethod(from: self.brewMethod ?? "V60")
    }
}