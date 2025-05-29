import SwiftUI
import CoreData
import Combine

@MainActor
class EditRoasterViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var formData: RoasterFormData
    @Published var focusedField: FocusedField?
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    @Published var isSaving = false
    
    // MARK: - Private Properties
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    private let originalFormData: RoasterFormData
    private let roaster: Roaster
    
    // MARK: - Computed Properties
    var headerTitle: String {
        "Edit Roaster"
    }
    
    var headerSubtitle: String {
        "Modify your roaster details."
    }
    
    var saveButtonTitle: String {
        "Save Changes"
    }
    
    // MARK: - Initialization
    init(roaster: Roaster, context: NSManagedObjectContext) {
        self.viewContext = context
        self.roaster = roaster
        
        // Initialize form data from existing roaster
        let roasterData = RoasterFormData(from: roaster)
        self.originalFormData = roasterData
        self.formData = roasterData
    }
    
    // MARK: - Public Methods
    func validateAndSave() {
        var missingFields: [String] = []
        
        if formData.name.isEmpty {
            missingFields.append("Roaster Name")
        }
        
        if missingFields.isEmpty {
            saveRoaster()
        } else {
            validationMessage = "Please fill in the following fields: \(missingFields.joined(separator: ", "))"
            showValidationAlert = true
        }
    }
    
    func hasUnsavedChanges() -> Bool {
        return formData != originalFormData
    }
    
    // MARK: - Private Methods
    private func saveRoaster() {
        isSaving = true
        
        withAnimation(.bouncy(duration: 0.5)) {
            // Update existing roaster with form data
            roaster.name = formData.name
            roaster.country = formData.country
            roaster.website = formData.website.isEmpty ? nil : formData.website
            roaster.notes = formData.notes.isEmpty ? nil : formData.notes
            roaster.foundedYear = Int16(formData.foundedYearInt ?? 0)
            
            do {
                try viewContext.save()
                
                // Post notification for any views that need to update
                NotificationCenter.default.post(name: .roasterUpdated, object: roaster)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isSaving = false
                }
            } catch {
                print("Error saving roaster: \(error)")
                self.isSaving = false
            }
        }
    }
}

extension Notification.Name {
    static let roasterUpdated = Notification.Name("roasterUpdated")
}