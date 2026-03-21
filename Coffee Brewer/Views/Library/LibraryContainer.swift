import SwiftUI
import CoreData

struct LibraryContainer: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            AllLibraryView(navigationCoordinator: navigationCoordinator, searchText: searchText)
                .padding(.horizontal, 20)
        }
        .sheet(item: $navigationCoordinator.editingRoaster) { roaster in
            NavigationStack {
                EditRoaster(roaster: roaster, isPresented: $navigationCoordinator.editingRoaster)
                    .environment(\.managedObjectContext, navigationCoordinator.editingRoaster?.managedObjectContext ?? PersistenceController.shared.container.viewContext)
            }
            .tint(BrewerColors.cream)
        }
        .sheet(item: $navigationCoordinator.editingGrinder) { grinder in
            NavigationStack {
                EditGrinder(grinder: grinder, isPresented: $navigationCoordinator.editingGrinder)
                    .environment(\.managedObjectContext, navigationCoordinator.editingGrinder?.managedObjectContext ?? PersistenceController.shared.container.viewContext)
            }
            .tint(BrewerColors.cream)
        }
    }
}
