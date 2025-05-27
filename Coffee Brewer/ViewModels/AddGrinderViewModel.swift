import SwiftUI
import CoreData

@MainActor
class AddGrinderViewModel: ObservableObject {
    @Published var formData = GrinderFormData()
    @Published var focusedField: FocusedField?
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    @Published var isSaving = false
    
    private let viewContext: NSManagedObjectContext
    
    var headerTitle: String {
        "New Grinder"
    }
    
    var headerSubtitle: String {
        "Add a coffee grinder to your collection"
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func validateAndSave() -> Bool {
        var missingFields: [String] = []
        
        if formData.name.isEmpty {
            missingFields.append("Grinder Name")
        }
        
        if formData.burrType.isEmpty {
            missingFields.append("Burr Type")
        }
        
        if formData.type.isEmpty {
            missingFields.append("Type")
        }
        
        if !missingFields.isEmpty {
            validationMessage = "Please, fill in \(missingFields[0])"
            showValidationAlert = true
            return false
        }
        
        if let burrSize = formData.burrSizeInt {
            if burrSize < 10 || burrSize > 200 {
                validationMessage = "Please enter a valid burr size (10-200mm)"
                showValidationAlert = true
                return false
            }
        }

        return saveGrinder()
    }
    
    private func saveGrinder() -> Bool {
        isSaving = true
        
        let grinder = Grinder(context: viewContext)
        grinder.id = UUID()
        grinder.name = formData.name.trimmingCharacters(in: .whitespacesAndNewlines)
        grinder.burrType = formData.burrType
        grinder.type = formData.type
        grinder.dosingType = formData.dosingType.isEmpty ? nil : formData.dosingType
        
        if let burrSize = formData.burrSizeInt {
            grinder.burrSize = Int16(burrSize)
        }
        
        do {
            try viewContext.save()
            isSaving = false
            NotificationCenter.default.post(name: .grinderSaved, object: nil)
            return true
        } catch {
            print("Failed to save grinder: \(error)")
            isSaving = false
            validationMessage = "Failed to save grinder"
            showValidationAlert = true
            return false
        }
    }
    
    func resetToDefaults() {
        formData = GrinderFormData()
        focusedField = nil
        showValidationAlert = false
        validationMessage = ""
        isSaving = false
    }
    
    func hasUnsavedChanges() -> Bool {
        !formData.name.isEmpty ||
        !formData.burrType.isEmpty ||
        !formData.burrSize.isEmpty ||
        !formData.dosingType.isEmpty ||
        !formData.type.isEmpty
    }
}

extension Notification.Name {
    static let grinderSaved = Notification.Name("grinderSaved")
}
