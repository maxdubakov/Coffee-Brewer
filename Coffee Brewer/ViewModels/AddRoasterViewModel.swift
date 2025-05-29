import SwiftUI
import CoreData

@MainActor
class AddRoasterViewModel: ObservableObject {
    @Published var formData = RoasterFormData()
    @Published var focusedField: FocusedField?
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    @Published var isSaving = false
    
    private let viewContext: NSManagedObjectContext
    
    var headerTitle: String {
        "New Roaster"
    }
    
    var headerSubtitle: String {
        "Add a coffee roaster to your collection"
    }
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func validateAndSave() -> Bool {
        var missingFields: [String] = []
        
        if formData.name.isEmpty {
            missingFields.append("Roaster Name")
        }
        
        if formData.country == nil {
            missingFields.append("Country")
        }
        
        if !missingFields.isEmpty {
            validationMessage = "Please, fill in \(missingFields[0])"
            showValidationAlert = true
            return false
        }
        
        
        if let foundedYear = formData.foundedYearInt {
            let currentYear = Calendar.current.component(.year, from: Date())
            if foundedYear < 1000 || foundedYear > currentYear {
                validationMessage = "Please enter a valid year"
                showValidationAlert = true
                return false
            }
        }
        
        if !formData.website.isEmpty, formData.websiteURL == nil {
            validationMessage = "Please enter a valid website URL"
            showValidationAlert = true
            return false
        }
        
        return saveRoaster()
    }
    
    private func saveRoaster() -> Bool {
        isSaving = true
        
        let roaster = Roaster(context: viewContext)
        roaster.id = UUID()
        roaster.name = formData.name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        roaster.country = formData.country
        roaster.website = formData.website.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        roaster.notes = formData.notes.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if let foundedYear = formData.foundedYearInt {
            roaster.foundedYear = Int16(foundedYear)
        }
        
        do {
            try viewContext.save()
            isSaving = false
            NotificationCenter.default.post(name: .roasterSaved, object: nil)
            return true
        } catch {
            print("Failed to save roaster: \(error)")
            isSaving = false
            validationMessage = "Failed to save roaster"
            showValidationAlert = true
            return false
        }
    }
    
    func resetToDefaults() {
        formData = RoasterFormData()
        focusedField = nil
        showValidationAlert = false
        validationMessage = ""
        isSaving = false
    }
    
    func hasUnsavedChanges() -> Bool {
        !formData.name.isEmpty ||
        formData.country != nil ||
        !formData.website.isEmpty ||
        !formData.notes.isEmpty ||
        !formData.foundedYear.isEmpty
    }
}

extension Notification.Name {
    static let roasterSaved = Notification.Name("roasterSaved")
}
