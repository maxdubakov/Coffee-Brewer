import SwiftUI

struct AddChoice: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    @Environment(\.managedObjectContext) private var viewContext
    
    init(navigationCoordinator: NavigationCoordinator) {
        self.navigationCoordinator = navigationCoordinator
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                    Text("Add New")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    Text("What would you like to add?")
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.textSecondary)
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 16) {
                    Button(action: {
                        navigationCoordinator.addPath.append(AppDestination.addRecipe(roaster: navigationCoordinator.selectedRoaster))
                    }) {
                        ChoiceCardContent(
                            title: "Recipe",
                            description: "Create a new coffee brewing recipe",
                            iconName: "plus.circle.fill"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        navigationCoordinator.addPath.append(AppDestination.addRoaster)
                    }) {
                        ChoiceCardContent(
                            title: "Roaster",
                            description: "Add a new coffee roaster",
                            iconName: "building.2.fill"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        navigationCoordinator.addPath.append(AppDestination.addGrinder)
                    }) {
                        ChoiceCardContent(
                            title: "Grinder",
                            description: "Add a new coffee grinder",
                            iconName: "gearshape.2.fill"
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, 24)
            .background(BrewerColors.background)
    }
}

struct ChoiceCardContent: View {
    let title: String
    let description: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(BrewerColors.caramel)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(BrewerColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(BrewerColors.surface)
            .cornerRadius(12)
    }
}

#Preview {
    @Previewable @State var selectedTab = Main.Tab.add
    @Previewable @State var selectedRoaster: Roaster? = nil
    
    GlobalBackground {
        AddChoice(navigationCoordinator: NavigationCoordinator())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
