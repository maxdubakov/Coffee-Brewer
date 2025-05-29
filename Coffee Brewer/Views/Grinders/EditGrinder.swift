import SwiftUI
import CoreData

struct EditGrinder: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let grinder: Grinder
    @Binding var isPresented: Grinder?
    
    @StateObject private var viewModel: EditGrinderViewModel
    @State private var showDiscardAlert = false
    
    init(grinder: Grinder, isPresented: Binding<Grinder?>) {
        self.grinder = grinder
        self._isPresented = isPresented
        
        // Create view model
        let context = grinder.managedObjectContext ?? PersistenceController.shared.container.viewContext
        self._viewModel = StateObject(wrappedValue: EditGrinderViewModel(grinder: grinder, context: context))
    }
    
    var body: some View {
        NavigationStack {
            FixedBottomLayout(
                content: {
                    GrinderForm(
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
        .onReceive(NotificationCenter.default.publisher(for: .grinderUpdated)) { notification in
            // Check if this notification is for our grinder
            if let updatedGrinder = notification.object as? Grinder,
               updatedGrinder.objectID == grinder.objectID {
                isPresented = nil
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    // Create a sample grinder for preview
    let grinder = Grinder(context: context)
    grinder.name = "Sample Grinder"
    grinder.type = "Manual"
    
    return EditGrinder(grinder: grinder, isPresented: .constant(grinder))
        .environment(\.managedObjectContext, context)
        .background(BrewerColors.background)
}