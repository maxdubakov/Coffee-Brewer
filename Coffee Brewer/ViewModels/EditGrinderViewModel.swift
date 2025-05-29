import SwiftUI
import CoreData
import Combine

@MainActor
class EditGrinderViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var formData: GrinderFormData
    @Published var focusedField: FocusedField?
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    @Published var isSaving = false
    
    // MARK: - Private Properties
    private let viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    private let originalFormData: GrinderFormData
    private let grinder: Grinder
    
    // MARK: - Computed Properties
    var headerTitle: String {
        "Edit Grinder"
    }
    
    var headerSubtitle: String {
        "Modify your grinder details."
    }
    
    var saveButtonTitle: String {
        "Save Changes"
    }
    
    // MARK: - Initialization
    init(grinder: Grinder, context: NSManagedObjectContext) {
        self.viewContext = context
        self.grinder = grinder
        
        // Initialize form data from existing grinder
        let grinderData = GrinderFormData(from: grinder)
        self.originalFormData = grinderData
        self.formData = grinderData
    }
    
    // MARK: - Public Methods
    func validateAndSave() {
        var missingFields: [String] = []
        
        if formData.name.isEmpty {
            missingFields.append("Grinder Name")
        }
        
        if missingFields.isEmpty {
            saveGrinder()
        } else {
            validationMessage = "Please fill in the following fields: \(missingFields.joined(separator: ", "))"
            showValidationAlert = true
        }
    }
    
    func hasUnsavedChanges() -> Bool {
        return formData != originalFormData
    }
    
    // MARK: - Private Methods
    private func saveGrinder() {
        isSaving = true
        
        withAnimation(.bouncy(duration: 0.5)) {
            // Update existing grinder with form data
            grinder.name = formData.name
            grinder.burrType = formData.burrType.isEmpty ? nil : formData.burrType
            grinder.burrSize = Int16(formData.burrSizeInt ?? 0)
            grinder.dosingType = formData.dosingType.isEmpty ? nil : formData.dosingType
            grinder.type = formData.type.isEmpty ? nil : formData.type
            
            do {
                try viewContext.save()
                
                // Post notification for any views that need to update
                NotificationCenter.default.post(name: .grinderUpdated, object: grinder)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isSaving = false
                }
            } catch {
                print("Error saving grinder: \(error)")
                self.isSaving = false
            }
        }
    }
}

extension Notification.Name {
    static let grinderUpdated = Notification.Name("grinderUpdated")
}