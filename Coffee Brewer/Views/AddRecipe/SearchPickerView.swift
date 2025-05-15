import SwiftUI
import CoreData

struct SearchPickerView<T: NSManagedObject>: View {
    @Environment(\.managedObjectContext) private var viewContext

    var label: String
    @Binding var selectedItem: T?
    var items: [T]
    var displayName: (T) -> String
    var createNewItem: (String) -> T?

    @State private var searchText: String = ""
    @State private var isEditing: Bool = false
    @Binding var focusedField: AddRecipe.FocusedField?
    @FocusState private var isFocused: Bool

    private var filteredItems: [T] {
        items.filter { searchText.isEmpty || displayName($0).localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text(label)
                                .font(.system(size: 17, weight: .light))
                                .foregroundColor(BrewerColors.placeholder)
                                .padding(.leading, 4)
                        }

                        TextField("", text: $searchText, onEditingChanged: { editing in
                            isEditing = editing
                        })
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(BrewerColors.textPrimary)
                        .keyboardType(.default)
                        .focused($isFocused)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .contentShape(Rectangle())
                    .onTapGesture { isEditing = true }

                    Spacer()

                    if !isEditing && selectedItem != nil {
                        Text(displayName(selectedItem!))
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(BrewerColors.textPrimary)
                            .onTapGesture {
                                isEditing = true
                            }
                    }
                }
                .padding(.vertical, 13.5)

                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(BrewerColors.divider)
            }

            if isEditing && !searchText.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    if !filteredItems.isEmpty {
                        ForEach(filteredItems, id: \.objectID) { item in
                            Button {
                                selectedItem = item
                                searchText = ""
                                isEditing = false
                                isFocused = false
                                focusedField = nil
                            } label: {
                                Text(displayName(item))
                                    .padding()
                                    .foregroundStyle(BrewerColors.textPrimary)
                            }
                            .background(BrewerColors.background)
                            .onTapGesture {
                                isEditing = false
                                focusedField = nil
                            }
                        }
                    } else {
                        Button {
                            if let newItem = createNewItem(searchText) {
                                selectedItem = newItem
                            }
                            searchText = ""
                            isEditing = false
                            isFocused = false
                            focusedField = nil
                        } label: {
                            Text("Create '\(searchText)'")
                                .foregroundColor(BrewerColors.textPrimary)
                                .padding()
                        }
                    }
                }
                .background(BrewerColors.background)
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(.top, 4)
            }
        }
    }
}
