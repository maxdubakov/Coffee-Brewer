import SwiftUI

struct SearchGrinderPicker: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - FetchRequest
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Grinder.name, ascending: true)],
        animation: .default
    ) private var grinders: FetchedResults<Grinder>

    // MARK: - Bindings
    @Binding var selectedGrinder: Grinder?
    @Binding var focusedField: AddRecipe.FocusedField?

    var body: some View {
        FormSearchPickerField<Grinder>(
            label: "Grinder",
            items: Array(grinders),
            displayName: { $0.name ?? "" },
            createNewItem: { name in
                let grinder = Grinder(context: viewContext)
                grinder.name = name
                return grinder
            },
            selectedItem: $selectedGrinder,
            focusedField: $focusedField,
        )
    }
}
