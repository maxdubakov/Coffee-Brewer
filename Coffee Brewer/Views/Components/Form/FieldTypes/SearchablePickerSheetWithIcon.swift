import SwiftUI
import CoreData

struct SearchablePickerSheetWithIcon<T: NSManagedObject, RowContent: View>: View {
    let label: String
    let items: [T]
    let searchKeyPath: (T) -> String
    let onSelect: (T) -> Void
    @ViewBuilder let rowContent: (T) -> RowContent

    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    private var filtered: [T] {
        items.filter {
            searchText.isEmpty || searchKeyPath($0).localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(filtered, id: \.objectID) { item in
                        Button {
                            onSelect(item)
                            dismiss()
                        } label: {
                            rowContent(item)
                                .foregroundColor(BrewerColors.textPrimary)
                        }
                        .listRowBackground(BrewerColors.background)
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