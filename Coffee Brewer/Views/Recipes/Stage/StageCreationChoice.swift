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
                    Button(action: {
                        navigationCoordinator.addPath.append(AppDestination.recordStages(formData: formData, existingRecipeID: existingRecipeID))
                    }) {
                        RecordChoiceCard()
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // OR divider
                    HStack(spacing: 16) {
                        Rectangle()
                            .fill(BrewerColors.divider)
                            .frame(height: 1)
                        
                        Text("OR")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(BrewerColors.textSecondary)
                        
                        Rectangle()
                            .fill(BrewerColors.divider)
                            .frame(height: 1)
                    }
                    .padding(.vertical, 8)
                    
                    // Manual option
                    Button(action: {
                        navigationCoordinator.addPath.append(AppDestination.stagesManagement(formData: formData, existingRecipeID: existingRecipeID))
                    }) {
                        ManualChoiceCard()
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.horizontal, 18)
                
                Spacer()
            }
            .background(BrewerColors.background)
        }
    }
}

struct RecordChoiceCard: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [BrewerColors.caramel.opacity(0.8), BrewerColors.caramel]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .strokeBorder(BrewerColors.caramel, lineWidth: 2)
                    )
                    .shadow(color: BrewerColors.buttonShadow, radius: 6, x: 0, y: 3)
                
                Image(systemName: "record.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(BrewerColors.cream)
            }
            
            VStack(spacing: 8) {
                Text("Record While Brewing")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(BrewerColors.textPrimary)
                
                Text("Tap to record stages as you brew")
                    .font(.system(size: 16))
                    .foregroundColor(BrewerColors.textSecondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                    Text("Recommended")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(BrewerColors.caramel)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(BrewerColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(BrewerColors.caramel.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct ManualChoiceCard: View {
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(BrewerColors.surface)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .strokeBorder(BrewerColors.divider, lineWidth: 1.5)
                    )
                
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 28))
                    .foregroundColor(BrewerColors.cream)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Create Manually")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(BrewerColors.textPrimary)
                
                Text("Define each stage individually")
                    .font(.system(size: 15))
                    .foregroundColor(BrewerColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(BrewerColors.surface.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(BrewerColors.divider, lineWidth: 1)
                )
        )
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonPressAnimation(isPressed: configuration.isPressed, duration: AnimationDurations.quickFade)
    }
}
