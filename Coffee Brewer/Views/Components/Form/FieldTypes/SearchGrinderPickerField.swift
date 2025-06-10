import SwiftUI
import CoreData

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
                    FormPlaceholderText(value: "None (pre-ground)")
                }
            }
            .onTapGesture {
                isPresentingSheet = true
            }
        }
        .sheet(isPresented: $isPresentingSheet) {
            GrinderPickerSheet(
                grinders: Array(grinders),
                onSelect: { selectedGrinder = $0 }
            )
        }
    }
}

// MARK: - Grinder Picker Sheet
private struct GrinderPickerSheet: View {
    let grinders: [Grinder]
    let onSelect: (Grinder?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    
    private var filteredItems: [(grinder: Grinder?, sortName: String)] {
        var items: [(grinder: Grinder?, sortName: String)] = []
        
        // Add pre-ground option if it matches search
        if searchText.isEmpty || "pre-ground".localizedCaseInsensitiveContains(searchText) || "none".localizedCaseInsensitiveContains(searchText) {
            items.append((grinder: nil, sortName: "None (pre-ground)"))
        }
        
        // Add filtered grinders
        let filtered = grinders.filter {
            searchText.isEmpty || ($0.name ?? "").localizedCaseInsensitiveContains(searchText)
        }
        items.append(contentsOf: filtered.map { (grinder: $0, sortName: $0.name ?? "") })
        
        // Sort all items alphabetically
        return items.sorted { $0.sortName.localizedCompare($1.sortName) == .orderedAscending }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(filteredItems, id: \.grinder?.objectID) { item in
                        Button {
                            onSelect(item.grinder)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                if let grinder = item.grinder {
                                    SVGIcon(grinder.typeIcon, size: 20, color: BrewerColors.caramel)
                                } else {
                                    Image(systemName: "bag")
                                        .font(.system(size: 20))
                                        .foregroundColor(BrewerColors.caramel)
                                        .frame(width: 20, height: 20)
                                }
                                
                                Text(item.sortName)
                                    .font(.body)
                                    .foregroundColor(BrewerColors.textPrimary)
                                
                                Spacer()
                            }
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
                    Text("Grinder")
                        .font(.headline)
                        .foregroundColor(BrewerColors.textPrimary)
                }
            }
        }
        .background(BrewerColors.background.ignoresSafeArea())
    }
}
