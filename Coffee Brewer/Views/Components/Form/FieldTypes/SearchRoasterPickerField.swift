import SwiftUI

struct SearchRoasterPickerField: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - FetchRequest
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    ) private var roasters: FetchedResults<Roaster>

    // MARK: - Bindings
    @Binding var selectedRoaster: Roaster?
    @Binding var focusedField: FocusedField?

    @State private var isPresentingSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                FormPlaceholderText(value: "Roaster")

                Spacer()

                if let roaster = selectedRoaster {
                    FormValueText(value: roaster.name ?? "") {
                        if let country = roaster.country, let flag = country.flag {
                            Text(flag)
                                .font(.system(size: 17))
                        }
                    }
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
                label: "Roaster",
                items: Array(roasters),
                displayName: { roaster in
                    let name = roaster.name ?? ""
                    if let country = roaster.country, let flag = country.flag {
                        return "\(flag) \(name)"
                    }
                    return name
                },
                onSelect: { selectedRoaster = $0 },
                createNewItem: { name in
                    let roaster = Roaster(context: viewContext)
                    roaster.id = UUID()
                    roaster.name = name
                    return roaster
                }
            )
            .environment(\.managedObjectContext, viewContext)
        }
    }
}
