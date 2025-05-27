import SwiftUI

struct SearchCountryPickerField: View {
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - FetchRequest
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Country.name, ascending: true)],
        animation: .default
    ) private var countries: FetchedResults<Country>

    // MARK: - Bindings
    @Binding var selectedCountry: Country?
    @Binding var focusedField: FocusedField?

    @State private var isPresentingSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormField {
                FormPlaceholderText(value: "Country")

                Spacer()

                if let country = selectedCountry {
                    FormValueText(value: country.name ?? "") {
                        if let flag = country.flag {
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
                label: "Country",
                items: Array(countries),
                displayName: { country in
                    let flag = country.flag ?? ""
                    let name = country.name ?? ""
                    return "\(flag) \(name)".trimmingCharacters(in: .whitespaces)
                },
                onSelect: { selectedCountry = $0 },
                createNewItem: nil
            )
            .environment(\.managedObjectContext, viewContext)
        }
    }
}