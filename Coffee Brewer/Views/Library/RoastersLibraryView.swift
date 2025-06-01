import SwiftUI
import CoreData

struct RoastersLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    let searchText: String
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Roaster.name, ascending: true)],
        animation: .default
    )
    private var roasters: FetchedResults<Roaster>
    
    @State private var showingDeleteAlert = false
    @State private var roasterToDelete: Roaster?
    @State private var isEditMode = false
    @State private var selectedRoasters: Set<NSManagedObjectID> = []
    @State private var selectedRoasterForDetail: Roaster?
    
    private var filteredRoasters: [Roaster] {
        let allRoasters = Array(roasters)
        
        if searchText.isEmpty {
            return allRoasters
        } else {
            return allRoasters.filter { roaster in
                let nameMatch = roaster.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let countryMatch = roaster.country?.name?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatch || countryMatch
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with edit/delete buttons
            if !filteredRoasters.isEmpty {
                HStack {
                    Button(isEditMode ? "Done" : "Edit") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedRoasters.removeAll()
                            }
                        }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(BrewerColors.caramel)
                    
                    Spacer()
                    
                    if isEditMode && !selectedRoasters.isEmpty {
                        Button("Delete") {
                            showingDeleteAlert = true
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 8)
            }
            
            if filteredRoasters.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(filteredRoasters.enumerated()), id: \.element.id) { index, roaster in
                    VStack(spacing: 0) {
                        RoasterLibraryRow(
                            roaster: roaster,
                            isEditMode: isEditMode,
                            isSelected: selectedRoasters.contains(roaster.objectID),
                            onTap: {
                                if isEditMode {
                                    toggleSelection(for: roaster)
                                } else {
                                    selectedRoasterForDetail = roaster
                                }
                            }
                        )
                        
                        if index < filteredRoasters.count - 1 {
                            CustomDivider()
                                .padding(.leading, 32)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .contextMenu {
                        Button {
                            navigationCoordinator.presentEditRoaster(roaster)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            roasterToDelete = roaster
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
        .alert("Delete Roaster\(selectedRoasters.count > 1 ? "s" : "")", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                if selectedRoasters.isEmpty {
                    roasterToDelete = nil
                }
            }
            Button("Delete", role: .destructive) {
                if !selectedRoasters.isEmpty {
                    deleteSelectedRoasters()
                } else if let roaster = roasterToDelete {
                    deleteRoaster(roaster)
                }
            }
        } message: {
            if !selectedRoasters.isEmpty {
                Text("Are you sure you want to delete \(selectedRoasters.count) roaster\(selectedRoasters.count == 1 ? "" : "s")? This will also delete all associated recipes.")
            } else {
                Text("Are you sure you want to delete \(roasterToDelete?.name ?? "this roaster")? This will also delete all associated recipes.")
            }
        }
        .sheet(item: $selectedRoasterForDetail) { roaster in
            RoasterDetailSheet(roaster: roaster)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var emptyStateView: some View {
        CenteredContent(verticalOffset: -70) {
            VStack(spacing: 16) {
                SVGIcon("roaster", size: 70, color: BrewerColors.caramel)
                
                Text(searchText.isEmpty ? "No roasters yet" : "No roasters found")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(BrewerColors.textPrimary)
                
                if searchText.isEmpty {
                    Text("Create your first roaster to get started")
                        .font(.system(size: 14))
                        .foregroundColor(BrewerColors.textSecondary)
                }
            }
        }
    }
    
    private func toggleSelection(for roaster: Roaster) {
        if selectedRoasters.contains(roaster.objectID) {
            selectedRoasters.remove(roaster.objectID)
        } else {
            selectedRoasters.insert(roaster.objectID)
        }
    }
    
    private func deleteSelectedRoasters() {
        withAnimation {
            for objectID in selectedRoasters {
                if let roaster = viewContext.object(with: objectID) as? Roaster {
                    viewContext.delete(roaster)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting roasters: \(error)")
            }
            
            selectedRoasters.removeAll()
            isEditMode = false
        }
    }
    
    private func deleteRoaster(_ roaster: Roaster) {
        withAnimation {
            viewContext.delete(roaster)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting roaster: \(error)")
            }
        }
        roasterToDelete = nil
    }
}
