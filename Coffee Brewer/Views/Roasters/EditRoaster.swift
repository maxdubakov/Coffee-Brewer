import SwiftUI
import CoreData

struct EditRoaster: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let roaster: Roaster
    @Binding var isPresented: Roaster?
    
    @StateObject private var viewModel: EditRoasterViewModel
    @State private var showDiscardAlert = false
    
    init(roaster: Roaster, isPresented: Binding<Roaster?>) {
        self.roaster = roaster
        self._isPresented = isPresented
        
        // Create view model
        let context = roaster.managedObjectContext ?? PersistenceController.shared.container.viewContext
        self._viewModel = StateObject(wrappedValue: EditRoasterViewModel(roaster: roaster, context: context))
    }
    
    var body: some View {
        NavigationStack {
            FixedBottomLayout(
                content: {
                    RoasterForm(
                        formData: $viewModel.formData,
                        focusedField: $viewModel.focusedField
                    )
                },
                actions: {
                    StandardButton(
                        title: viewModel.saveButtonTitle,
                        iconName: "checkmark.circle.fill",
                        action: viewModel.validateAndSave,
                        style: .primary
                    )
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if viewModel.hasUnsavedChanges() {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(viewModel.headerTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(BrewerColors.cream)
                    }
                }
            }
            .alert(isPresented: $viewModel.showValidationAlert) {
                Alert(
                    title: Text("Incomplete Information"),
                    message: Text(viewModel.validationMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("You have unsaved changes. Are you sure you want to discard them?")
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: BrewerColors.caramel))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .roasterUpdated)) { notification in
            // Check if this notification is for our roaster
            if let updatedRoaster = notification.object as? Roaster,
               updatedRoaster.objectID == roaster.objectID {
                isPresented = nil
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Create a sample roaster for preview
    let roaster = Roaster(context: context)
    roaster.name = "Sample Roaster"
    roaster.location = "Sample City"
    
    return EditRoaster(roaster: roaster, isPresented: .constant(roaster))
        .environment(\.managedObjectContext, context)
        .background(BrewerColors.background)
}