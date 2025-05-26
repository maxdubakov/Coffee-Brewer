import SwiftUI

struct SearchGrinderPickerField: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext
    
    // MARK: - FetchRequest
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Grinder.name, ascending: true)],
        animation: .default
    ) private var grinders: FetchedResults<Grinder>

    // MARK: - Bindings
    @Binding var selectedGrinder: Grinder?
    @Binding var focusedField: FocusedField?
    
    @State private var isPresentingSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                FormPlaceholderText(value: "Grinder")

                Spacer()

                if let grinder = selectedGrinder {
                    FormValueText(value: grinder.name ?? "")
                } else {
                    FormPlaceholderText(value: "Select")
                }
            }
            .onTapGesture {
                isPresentingSheet = true
            }

            
        }
        .sheet(isPresented: $isPresentingSheet) {
            SearchablePickerSheet(
                label: "Grinder",
                items: Array(grinders),
                displayName: { $0.name ?? "" },
                onSelect: { selectedGrinder = $0 },
                createNewItem: { name in
                    let grinder = Grinder(context: viewContext)
                    grinder.id = UUID()
                    grinder.name = name
                    return grinder
                }
            )
            .environment(\.managedObjectContext, viewContext)
        }
    }
}
