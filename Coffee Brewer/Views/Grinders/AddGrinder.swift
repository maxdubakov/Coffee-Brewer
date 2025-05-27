import SwiftUI
import CoreData

struct AddGrinder: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: AddGrinderViewModel
    
    init(context: NSManagedObjectContext? = nil) {
        let ctx = context ?? PersistenceController.shared.container.viewContext
        self._viewModel = StateObject(wrappedValue: AddGrinderViewModel(context: ctx))
    }
    
    var body: some View {
        FixedBottomLayout(
            content: {
                VStack(spacing: 16) {
                    PageTitleH2("Add Grinder", subtitle: "Add a coffee grinder to your collection")

                    GrinderForm(
                        formData: $viewModel.formData,
                        focusedField: $viewModel.focusedField
                    )
                }
            },
            actions: {
                StandardButton(
                    title: "Save Grinder",
                    iconName: "checkmark.circle.fill",
                    action: {
                        if viewModel.validateAndSave() {
                            dismiss()
                        }
                    },
                    style: .primary
                )
            }
        )
        .alert(isPresented: $viewModel.showValidationAlert) {
            Alert(
                title: Text("Validation Error"),
                message: Text(viewModel.validationMessage),
                dismissButton: .default(Text("OK"))
            )
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
}

#Preview {
    GlobalBackground {
        NavigationStack {
            AddGrinder(context: PersistenceController.preview.container.viewContext)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}