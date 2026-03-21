import SwiftUI
import CoreData

@MainActor
class AddCoffeeViewModel: ObservableObject {
    @Published var formData: CoffeeFormData
    @Published var focusedField: FocusedField?
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    @Published var isSaving = false

    private let viewContext: NSManagedObjectContext
    private let originalFormData: CoffeeFormData

    var headerTitle: String {
        "New Coffee"
    }

    var headerSubtitle: String {
        "Add a coffee to your collection"
    }

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        var defaultData = CoffeeFormData()
        defaultData.process = "Washed"
        self.formData = defaultData
        self.originalFormData = defaultData
    }

    func validateAndSave() -> Bool {
        if formData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please, fill in Coffee Name"
            showValidationAlert = true
            return false
        }

        return saveCoffee()
    }

    private func saveCoffee() -> Bool {
        isSaving = true

        let coffee = Coffee(context: viewContext)
        coffee.id = UUID()
        coffee.name = formData.name.trimmingCharacters(in: .whitespacesAndNewlines)
        coffee.process = formData.process.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = formData.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        coffee.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
        coffee.roaster = formData.roaster
        coffee.country = formData.country
        coffee.createdAt = Date()

        do {
            try viewContext.save()
            isSaving = false
            NotificationCenter.default.post(name: .coffeeSaved, object: nil)
            return true
        } catch {
            print("Failed to save coffee: \(error)")
            isSaving = false
            validationMessage = "Failed to save coffee"
            showValidationAlert = true
            return false
        }
    }

    func resetToDefaults() {
        var defaultData = CoffeeFormData()
        defaultData.process = "Washed"
        formData = defaultData
        focusedField = nil
        showValidationAlert = false
        validationMessage = ""
        isSaving = false
    }

    func hasUnsavedChanges() -> Bool {
        formData != originalFormData
    }
}

extension Notification.Name {
    static let coffeeSaved = Notification.Name("coffeeSaved")
    static let coffeeUpdated = Notification.Name("coffeeUpdated")
}
