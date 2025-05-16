import SwiftUI
import CoreData

struct FormSearchPickerField<T: NSManagedObject>: View {
    // MARK: - Public Properties
    let label: String
    var items: [T]
    var displayName: (T) -> String
    var createNewItem: (String) -> T?
    
    // MARK: - Environment
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Bindings
    @Binding var selectedItem: T?
    @Binding var focusedField: AddRecipe.FocusedField?
    
    // MARK: - State
    @State private var searchText: String = ""

    // MARK: - Focus State
    @FocusState private var isFocused: Bool

    // MARK: - Computed Properties
    private var filteredItems: [T] {
        items.filter { searchText.isEmpty || displayName($0).localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                FormField {
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            FormPlaceholderText(value: label)
                        }
                        FormValueText(
                            placeholder: "",
                            textBinding: Binding(
                                get: {searchText},
                                set: {searchText = $0}
                            ),
                            isFocused: $isFocused
                        )
                        .keyboardType(.default)
                        .onChange(of: isFocused) { oldValue, newValue in
                            if newValue, let selected = selectedItem {
                                searchText = displayName(selected)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if !isFocused && selectedItem != nil {
                        FormValueText(value: displayName(selectedItem!))
                    }
                }
                .onTapGesture {
                    isFocused = true
                }

                Divider()
            }
            .onChange(of: isFocused) {oldValue, newValue in
                if !newValue {
                    searchText = ""
                    isFocused = false
                }
            }

            if isFocused && !searchText.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    if !filteredItems.isEmpty {
                        ForEach(filteredItems, id: \.objectID) { item in
                            Button {
                                selectedItem = item
                                searchText = ""
                                isFocused = false
                                focusedField = nil
                            } label: {
                                FormValueText(value: displayName(item))
                                    .padding()
                            }
                            .onTapGesture {
                                isFocused = false
                                focusedField = nil
                            }
                        }
                    } else {
                        Button {
                            if let newItem = createNewItem(searchText) {
                                selectedItem = newItem
                            }
                            searchText = ""
                            isFocused = false
                            focusedField = nil
                        } label: {
                            Text("Create '\(searchText)'")
                                .foregroundColor(BrewerColors.textPrimary)
                                .padding()
                        }
                    }
                }
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(.top, 4)
            }
        }
    }
}
