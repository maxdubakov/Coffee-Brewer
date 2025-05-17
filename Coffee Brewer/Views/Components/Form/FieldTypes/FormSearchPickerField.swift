import SwiftUI
import CoreData

struct SearchablePickerSheet<T: NSManagedObject>: View {
    let label: String
    let items: [T]
    let displayName: (T) -> String
    let onSelect: (T) -> Void
    let createNewItem: ((String) -> T?)?

    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    private var filtered: [T] {
        items.filter {
            searchText.isEmpty || displayName($0).localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if !searchText.isEmpty {
                        ForEach(filtered, id: \.objectID) { item in
                            Button {
                                onSelect(item)
                                dismiss()
                            } label: {
                                Text(displayName(item))
                                    .foregroundColor(BrewerColors.textPrimary)
                            }
                            .listRowBackground(BrewerColors.background)
                        }

                        if filtered.isEmpty, let create = createNewItem {
                            Button {
                                if let new = create(searchText) {
                                    onSelect(new)
                                    dismiss()
                                }
                            } label: {
                                Text("Create '\(searchText)'")
                                    .foregroundColor(BrewerColors.textPrimary)
                            }
                            .listRowBackground(BrewerColors.background)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(BrewerColors.background)
            .searchable(text: $searchText, prompt: "Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(BrewerColors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(label)
                        .font(.headline)
                        .foregroundColor(BrewerColors.textPrimary)
                }
            }
        }
        .background(BrewerColors.background.ignoresSafeArea())
    }
}
