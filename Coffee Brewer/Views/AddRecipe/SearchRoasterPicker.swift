import SwiftUI

struct SearchRoasterPicker: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    ) private var roasters: FetchedResults<Roaster>

    @Binding var selectedRoaster: Roaster?
    @Binding var focusedField: AddRecipe.FocusedField?

    var body: some View {
        SearchPickerView<Roaster>(
            label: "Roaster",
            selectedItem: $selectedRoaster,
            items: Array(roasters),
            displayName: { $0.name ?? "Unnamed" },
            createNewItem: { name in
                let roaster = Roaster(context: viewContext)
                roaster.name = name
                return roaster
            },
            focusedField: $focusedField,
        )
    }
}
