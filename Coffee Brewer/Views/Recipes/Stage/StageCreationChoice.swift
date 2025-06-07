import SwiftUI
import CoreData

struct StageCreationChoice: View {
    let formData: RecipeFormData
    let existingRecipeID: NSManagedObjectID?
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        GlobalBackground {
            VStack(spacing: 0) {
                // Header
                PageTitleH2("Add Brewing Stages", subtitle: "Choose how you'd like to create your brewing stages")
                    .padding(.vertical, 20)
                
                // Choice cards
                VStack(spacing: 20) {
                    // Record option
                    ChoiceCard(
                        title: "Record While Brewing",
                        description: "Tap to record stages as you brew",
                        icon: .system("record.circle.fill"),
                        style: .primary,
                        badgeText: "Recommended",
                        action: {
                            navigationCoordinator.addPath.append(AppDestination.recordStages(formData: formData, existingRecipeID: existingRecipeID))
                        }
                    )
                    
                    // OR divider
                    ChoiceDivider()
                    
                    // Manual option
                    ChoiceCard(
                        title: "Create Manually",
                        description: "Define each stage individually",
                        icon: .system("square.and.pencil"),
                        style: .secondary,
                        action: {
                            navigationCoordinator.addPath.append(AppDestination.stagesManagement(formData: formData, existingRecipeID: existingRecipeID))
                        }
                    )
                }
                .padding(.horizontal, 18)
                
                Spacer()
            }
            .background(BrewerColors.background)
        }
    }
}
