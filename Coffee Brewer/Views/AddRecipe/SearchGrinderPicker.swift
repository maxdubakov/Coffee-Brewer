import SwiftUI

struct SearchGrinderPicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Grinder.name, ascending: true)],
        animation: .default
    ) private var grinders: FetchedResults<Grinder>

    @Binding var selectedGrinder: Grinder?
    @Binding var focusedField: AddRecipe.FocusedField?

    var body: some View {
        FormSearchPickerField<Grinder>(
            label: "Grinder",
            selectedItem: $selectedGrinder,
            items: Array(grinders),
            displayName: { $0.name ?? "" },
            createNewItem: { name in
                let grinder = Grinder(context: viewContext)
                grinder.name = name
                return grinder
            },
            focusedField: $focusedField,
        )
    }
}
