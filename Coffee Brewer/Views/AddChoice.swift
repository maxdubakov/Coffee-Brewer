import SwiftUI

struct AddChoice: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    @Environment(\.managedObjectContext) private var viewContext
    
    init(navigationCoordinator: NavigationCoordinator) {
        self.navigationCoordinator = navigationCoordinator
    }
    
    var body: some View {
        VStack(spacing: 24) {
            PageTitleH1("Add New", subtitle: "What would you like to add?")
            
            VStack(spacing: 16) {
                Button(action: {
                    navigationCoordinator.addPath.append(AppDestination.addRecipe(roaster: navigationCoordinator.selectedRoaster, grinder: navigationCoordinator.selectedGrinder))
                }) {
                    ChoiceCardContent(
                        title: "Recipe",
                        description: "Create a new coffee brewing recipe",
                        imageName: "v60.icon"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    navigationCoordinator.addPath.append(AppDestination.addRoaster)
                }) {
                    ChoiceCardContent(
                        title: "Roaster",
                        description: "Add a new coffee roaster",
                        imageName: "roaster"
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    navigationCoordinator.addPath.append(AppDestination.addGrinder)
                }) {
                    ChoiceCardContent(
                        title: "Grinder",
                        description: "Add a new coffee grinder",
                        imageName: "grinder"
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .background(BrewerColors.background)
        .onAppear {
            // Clear selectedGrinder when showing AddChoice normally
            // It should only be set when coming from Welcome flow
            if navigationCoordinator.addPath.isEmpty {
                navigationCoordinator.selectedGrinder = nil
            }
        }
    }
}

struct ChoiceCardContent: View {
    let title: String
    let description: String
    let imageName: String
    
    var body: some View {
        HStack(spacing: 16) {
            SVGIcon(imageName, size: 40, color: BrewerColors.caramel)
            
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
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                BrewerColors.cardBackground,
                                BrewerColors.cardBackground.opacity(0.9),
                                BrewerColors.caramel.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
        )
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
