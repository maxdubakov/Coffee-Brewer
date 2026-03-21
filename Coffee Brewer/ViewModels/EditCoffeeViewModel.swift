import SwiftUI
import CoreData

@MainActor
class EditCoffeeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var formData: CoffeeFormData
    @Published var focusedField: FocusedField?
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    @Published var isSaving = false

    // MARK: - Private Properties
    private let viewContext: NSManagedObjectContext
    private let originalFormData: CoffeeFormData
    private let coffee: Coffee

    // MARK: - Computed Properties
    var headerTitle: String {
        "Edit Coffee"
    }

    var headerSubtitle: String {
        "Modify your coffee details."
    }

    var saveButtonTitle: String {
        "Save Changes"
    }

    // MARK: - Initialization
    init(coffee: Coffee, context: NSManagedObjectContext) {
        self.viewContext = context
        self.coffee = coffee

        let coffeeData = CoffeeFormData(from: coffee)
        self.originalFormData = coffeeData
        self.formData = coffeeData
    }

    // MARK: - Public Methods
    func validateAndSave() {
        if formData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please fill in the following fields: Coffee Name"
            showValidationAlert = true
            return
        }

        saveCoffee()
    }

    func hasUnsavedChanges() -> Bool {
        return formData != originalFormData
    }

    // MARK: - Private Methods
    private func saveCoffee() {
        isSaving = true

        withAnimation(.bouncy(duration: 0.5)) {
            coffee.name = formData.name.trimmingCharacters(in: .whitespacesAndNewlines)
            coffee.process = formData.process.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedNotes = formData.notes.trimmingCharacters(in: .whitespacesAndNewlines)
            coffee.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            coffee.roaster = formData.roaster
            coffee.country = formData.country

            do {
                try viewContext.save()

                NotificationCenter.default.post(name: .coffeeUpdated, object: coffee)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isSaving = false
                }
            } catch {
                print("Error saving coffee: \(error)")
                self.isSaving = false
                self.validationMessage = "Failed to save coffee"
                self.showValidationAlert = true
            }
        }
    }
}
