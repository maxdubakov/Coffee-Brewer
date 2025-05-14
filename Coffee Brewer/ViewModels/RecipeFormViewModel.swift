//
//  RecipeFormViewModel.swift
//  Coffee Brewer
//
//  Created by Maxim on 14/05/2025.
//


import Foundation
import CoreData

final class RecipeFormViewModel: ObservableObject {
    @Published var form = RecipeFormModel()
    let context: NSManagedObjectContext
    let existingRoaster: Roaster?

    init(context: NSManagedObjectContext, existingRoaster: Roaster? = nil) {
        self.context = context
        self.existingRoaster = existingRoaster

        if let roaster = existingRoaster {
            form.roasterName = roaster.name ?? ""
        }
    }

    func saveRecipe(onSuccess: @escaping () -> Void) {
        context.perform {
            let roaster: Roaster

            if let existing = self.existingRoaster {
                roaster = existing
            } else {
                let request: NSFetchRequest<Roaster> = Roaster.fetchRequest()
                request.predicate = NSPredicate(format: "name == %@", self.form.roasterName)
                roaster = (try? self.context.fetch(request).first) ?? {
                    let newRoaster = Roaster(context: self.context)
                    newRoaster.name = self.form.roasterName
                    return newRoaster
                }()
            }

            let recipe = Recipe(context: self.context)
            recipe.name = self.form.recipeName
            recipe.grams = Int16(self.form.coffeeGrams) ?? 18
            recipe.lastBrewedAt = Date()
            recipe.roaster = roaster

            do {
                try self.context.save()
                onSuccess()
            } catch {
                print("Save failed: \(error)")
            }
        }
    }
}
