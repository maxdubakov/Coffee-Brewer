import SwiftUI

struct SearchRoasterPicker: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - Fetch Request
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    ) private var roasters: FetchedResults<Roaster>

    // MARK: - Bindings
    @Binding var selectedRoaster: Roaster?
    @Binding var focusedField: AddRecipe.FocusedField?

    var body: some View {
        FormSearchPickerField<Roaster>(
            label: "Roaster",
            items: Array(roasters),
            displayName: { $0.name ?? "" },
            createNewItem: { name in
                let roaster = Roaster(context: viewContext)
                roaster.name = name
                return roaster
            },
            selectedItem: $selectedRoaster,
            focusedField: $focusedField,
        )
    }
}
