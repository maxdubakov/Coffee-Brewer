import SwiftUI
import CoreData

struct SearchRoasterPicker: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var selectedRoaster: Roaster?

    @State private var searchText: String = ""
    @State private var isEditing: Bool = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    ) private var allRoasters: FetchedResults<Roaster>

    var filteredRoasters: [Roaster] {
        allRoasters.filter {
            searchText.isEmpty || ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header (label + text field style)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text("Roaster")
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
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isEditing = true
                    }

                    
                    Spacer()

                    ZStack(alignment: .trailing) {
                        if !isEditing && selectedRoaster !== nil {
                            Text(searchText.isEmpty ? (selectedRoaster?.name ?? "") : searchText)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(BrewerColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    isEditing = true
                                }
                        }
                    }
                }
                .padding(.vertical, 13.5)

                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(BrewerColors.divider)
            }

            // Dropdown suggestions
            if isEditing && !searchText.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    if !filteredRoasters.isEmpty {
                        ForEach(filteredRoasters, id: \.objectID) { roaster in
                            Button(action: {
                                selectedRoaster = roaster
                                searchText = ""
                                isEditing = false
                            }) {
                                Text(roaster.name ?? "Unnamed")
                                    .padding()
                                    .foregroundStyle(BrewerColors.textPrimary)
                            }
                            .background(BrewerColors.background)
                        }
                    } else {
                        Button(action: {
                            let newRoaster = Roaster(context: viewContext)
                            newRoaster.name = searchText
                            selectedRoaster = newRoaster
                            searchText = ""
                            isEditing = false
                        }) {
                            Text("Create")
                                .foregroundColor(BrewerColors.textPrimary)
                                .padding()
                        }
                    }
                }
                .background(BrewerColors.coffee)
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(.top, 4)
            }
        }
    }
}
