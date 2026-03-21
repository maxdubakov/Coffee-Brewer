import SwiftUI
import CoreData

struct EditCoffee: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let coffee: Coffee
    @Binding var isPresented: Coffee?

    @StateObject private var viewModel: EditCoffeeViewModel
    @State private var showDiscardAlert = false

    init(coffee: Coffee, isPresented: Binding<Coffee?>) {
        self.coffee = coffee
        self._isPresented = isPresented

        let context = coffee.managedObjectContext ?? PersistenceController.shared.container.viewContext
        self._viewModel = StateObject(wrappedValue: EditCoffeeViewModel(coffee: coffee, context: context))
    }

    var body: some View {
        NavigationStack {
            FixedBottomLayout(
                content: {
                    CoffeeForm(
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
        .onReceive(NotificationCenter.default.publisher(for: .coffeeUpdated)) { notification in
            if let updatedCoffee = notification.object as? Coffee,
               updatedCoffee.objectID == coffee.objectID {
                isPresented = nil
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext

    let coffee = Coffee(context: context)
    coffee.name = "Ethiopian Yirgacheffe"
    coffee.process = "Natural"

    return EditCoffee(coffee: coffee, isPresented: .constant(coffee))
        .environment(\.managedObjectContext, context)
        .background(BrewerColors.background)
}
