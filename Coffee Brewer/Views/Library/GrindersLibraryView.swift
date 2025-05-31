import SwiftUI
import CoreData

struct GrindersLibraryView: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    let searchText: String
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Grinder.name, ascending: true)],
        animation: .default
    )
    private var grinders: FetchedResults<Grinder>
    
    @State private var showingDeleteAlert = false
    @State private var grinderToDelete: Grinder?
    @State private var isEditMode = false
    @State private var selectedGrinders: Set<NSManagedObjectID> = []
    @State private var selectedGrinderForDetail: Grinder?
    
    private var filteredGrinders: [Grinder] {
        let allGrinders = Array(grinders)
        
        if searchText.isEmpty {
            return allGrinders
        } else {
            return allGrinders.filter { grinder in
                let nameMatch = grinder.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let typeMatch = grinder.type?.localizedCaseInsensitiveContains(searchText) ?? false
                let burrTypeMatch = grinder.burrType?.localizedCaseInsensitiveContains(searchText) ?? false
                return nameMatch || typeMatch || burrTypeMatch
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with edit/delete buttons
            if !filteredGrinders.isEmpty {
                HStack {
                    Button(isEditMode ? "Done" : "Edit") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isEditMode.toggle()
                            if !isEditMode {
                                selectedGrinders.removeAll()
                            }
                        }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(BrewerColors.caramel)
                    
                    Spacer()
                    
                    if isEditMode && !selectedGrinders.isEmpty {
                        Button("Delete") {
                            showingDeleteAlert = true
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.red)
                    }
                }
                .padding(.bottom, 8)
            }
            
            if filteredGrinders.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(Array(filteredGrinders.enumerated()), id: \.element.id) { index, grinder in
                    VStack(spacing: 0) {
                        GrinderLibraryRow(
                            grinder: grinder,
                            isEditMode: isEditMode,
                            isSelected: selectedGrinders.contains(grinder.objectID),
                            onTap: {
                                if isEditMode {
                                    toggleSelection(for: grinder)
                                } else {
                                    selectedGrinderForDetail = grinder
                                }
                            }
                        )
                        
                        if index < filteredGrinders.count - 1 {
                            CustomDivider()
                                .padding(.leading, 44)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .contextMenu {
                        Button {
                            navigationCoordinator.presentEditGrinder(grinder)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            grinderToDelete = grinder
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
        .alert("Delete Grinder\(selectedGrinders.count > 1 ? "s" : "")", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                if selectedGrinders.isEmpty {
                    grinderToDelete = nil
                }
            }
            Button("Delete", role: .destructive) {
                if !selectedGrinders.isEmpty {
                    deleteSelectedGrinders()
                } else if let grinder = grinderToDelete {
                    deleteGrinder(grinder)
                }
            }
        } message: {
            if !selectedGrinders.isEmpty {
                Text("Are you sure you want to delete \(selectedGrinders.count) grinder\(selectedGrinders.count == 1 ? "" : "s")? Associated recipes will keep their data but lose grinder reference.")
            } else {
                Text("Are you sure you want to delete \(grinderToDelete?.name ?? "this grinder")? Associated recipes will keep their data but lose grinder reference.")
            }
        }
        .sheet(item: $selectedGrinderForDetail) { grinder in
            GrinderDetailSheet(grinder: grinder)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "gear" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(BrewerColors.textSecondary.opacity(0.5))
            
            Text(searchText.isEmpty ? "No grinders yet" : "No grinders found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
            
            if searchText.isEmpty {
                Text("Create your first grinder to get started")
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    private func toggleSelection(for grinder: Grinder) {
        if selectedGrinders.contains(grinder.objectID) {
            selectedGrinders.remove(grinder.objectID)
        } else {
            selectedGrinders.insert(grinder.objectID)
        }
    }
    
    private func deleteSelectedGrinders() {
        withAnimation {
            for objectID in selectedGrinders {
                if let grinder = viewContext.object(with: objectID) as? Grinder {
                    viewContext.delete(grinder)
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error deleting grinders: \(error)")
            }
            
            selectedGrinders.removeAll()
            isEditMode = false
        }
    }
    
    private func deleteGrinder(_ grinder: Grinder) {
        withAnimation {
            viewContext.delete(grinder)
            do {
                try viewContext.save()
            } catch {
                print("Error deleting grinder: \(error)")
            }
        }
        grinderToDelete = nil
    }
}
