import SwiftUI
import CoreData

struct BrewsLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    let searchText: String
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Brew.date, ascending: false)],
        animation: .default
    )
    private var brews: FetchedResults<Brew>
    
    @State private var showingDeleteAlert = false
    @State private var brewToDelete: Brew?
    @State private var isEditMode = false
    @State private var selectedBrews: Set<NSManagedObjectID> = []
    @State private var selectedBrewForDetail: Brew?
    
    private var filteredBrews: [Brew] {
        let allBrews = Array(brews)
        
        if searchText.isEmpty {
            return allBrews
        } else {
            return allBrews.filter { brew in
                let nameMatch = brew.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let recipeNameMatch = brew.recipeName?.localizedCaseInsensitiveContains(searchText) ?? false
                let roasterNameMatch = brew.roasterName?.localizedCaseInsensitiveContains(searchText) ?? false
                let notesMatch = brew.notes?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatch || recipeNameMatch || roasterNameMatch || notesMatch
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with edit/delete buttons
            if !filteredBrews.isEmpty {
                HStack {
                    Button(isEditMode ? "Done" : "Edit") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedBrews.removeAll()
                            }
                        }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(BrewerColors.caramel)
                    
                    Spacer()
                    
                    if isEditMode && !selectedBrews.isEmpty {
                        Button("Delete") {
                            showingDeleteAlert = true
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 8)
            }
            
            if filteredBrews.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(filteredBrews.enumerated()), id: \.element.id) { index, brew in
                    VStack(spacing: 0) {
                        BrewLibraryRow(
                            brew: brew,
                            isEditMode: isEditMode,
                            isSelected: selectedBrews.contains(brew.objectID),
                            onTap: {
                                if isEditMode {
                                    toggleSelection(for: brew)
                                } else {
                                    selectedBrewForDetail = brew
                                }
                            }
                        )
                        
                        if index < filteredBrews.count - 1 {
                            CustomDivider()
                                .padding(.leading, 44)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .contextMenu {
                        Button(role: .destructive) {
                            brewToDelete = brew
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .scrollDismissesKeyboard(.immediately)
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .alert("Delete Brew\(selectedBrews.count > 1 ? "s" : "")", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                if selectedBrews.isEmpty {
                    brewToDelete = nil
                }
            }
            Button("Delete", role: .destructive) {
                if !selectedBrews.isEmpty {
                    deleteSelectedBrews()
                } else if let brew = brewToDelete {
                    deleteBrew(brew)
                }
            }
        } message: {
            if !selectedBrews.isEmpty {
                Text("Are you sure you want to delete \(selectedBrews.count) brew\(selectedBrews.count == 1 ? "" : "s")?")
            } else {
                Text("Are you sure you want to delete this brew?")
            }
        }
        .sheet(item: $selectedBrewForDetail) { brew in
            BrewDetailSheet(brew: brew)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var emptyStateView: some View {
        CenteredContent(verticalOffset: -70) {
            VStack(spacing: 16) {
                SVGIcon("coffee.beans", size: 70, color: BrewerColors.caramel)
                
                Text(searchText.isEmpty ? "No brews yet" : "No brews found")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(BrewerColors.textPrimary)
                
                if searchText.isEmpty {
                    Text("Start brewing to track your coffee journey")
                        .font(.system(size: 14))
                        .foregroundColor(BrewerColors.textSecondary)
                }
            }
        }
    }
    
    private func toggleSelection(for brew: Brew) {
        if selectedBrews.contains(brew.objectID) {
            selectedBrews.remove(brew.objectID)
        } else {
            selectedBrews.insert(brew.objectID)
        }
    }
    
    private func deleteSelectedBrews() {
        withAnimation {
            for objectID in selectedBrews {
                if let brew = viewContext.object(with: objectID) as? Brew {
                    viewContext.delete(brew)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting brews: \(error)")
            }
            
            selectedBrews.removeAll()
            isEditMode = false
        }
    }
    
    private func deleteBrew(_ brew: Brew) {
        withAnimation {
            viewContext.delete(brew)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting brew: \(error)")
            }
        }
        brewToDelete = nil
    }
}
