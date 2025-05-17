import SwiftUI

struct SearchRoasterPicker: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - FetchRequest
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    ) private var roasters: FetchedResults<Roaster>

    // MARK: - Bindings
    @Binding var selectedRoaster: Roaster?
    @Binding var focusedField: AddRecipe.FocusedField?

    @State private var isPresentingSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                FormPlaceholderText(value: "Roaster")

                Spacer()

                if let roaster = selectedRoaster {
                    FormValueText(value: roaster.name ?? "")
                } else {
                    FormPlaceholderText(value: "Select")
                }
            }
            .onTapGesture {
                isPresentingSheet = true
            }

            Divider()
        }
        .sheet(isPresented: $isPresentingSheet) {
            SearchablePickerSheet(
                label: "Roaster",
                items: Array(roasters),
                displayName: { $0.name ?? "" },
                onSelect: { selectedRoaster = $0 },
                createNewItem: { name in
                    let roaster = Roaster(context: viewContext)
                    roaster.name = name
                    return roaster
                }
            )
            .environment(\.managedObjectContext, viewContext)
        }

    }
}
