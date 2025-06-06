import SwiftUI
import CoreData

struct AddChoice: View {
    @ObservedObject var navigationCoordinator: NavigationCoordinator
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showPrimaryChoice = false
    @State private var showSecondaryChoices = false
    @State private var roasterCount = 0
    @State private var grinderCount = 0
    @State private var recipeCount = 0
    
    init(navigationCoordinator: NavigationCoordinator) {
        self.navigationCoordinator = navigationCoordinator
    }
    
    var needsRoaster: Bool {
        roasterCount == 0
    }
    
    var needsGrinder: Bool {
        grinderCount == 0
    }
    
    var shouldShowGuidance: Bool {
        needsRoaster || needsGrinder
    }
    
    var body: some View {
        VStack(spacing: 24) {
            PageTitleH1("Add New", subtitle: shouldShowGuidance ? "Let's set up your brewing essentials" : "What would you like to add?")
            
            if shouldShowGuidance {
                GuidanceCard()
                    .opacity(showPrimaryChoice ? 1 : 0)
                    .offset(y: showPrimaryChoice ? 0 : 20)
            }
            
            VStack(spacing: 20) {
                if needsRoaster {
                    // Primary: Roaster
                    PrimaryChoiceCard(
                        title: "Add Roaster",
                        description: "Add your coffee source first",
                        imageName: "roaster",
                        badgeText: "Required First",
                        action: {
                            navigationCoordinator.addPath.append(AppDestination.addRoaster)
                        }
                    )
                    .opacity(showPrimaryChoice ? 1 : 0)
                    .offset(y: showPrimaryChoice ? 0 : 30)
                    
                    ORDivider()
                        .opacity(showSecondaryChoices ? 1 : 0)
                    
                    VStack(spacing: 12) {
                        SecondaryChoiceCard(
                            title: "Recipe",
                            description: "Add roaster first",
                            imageName: "v60.icon",
                            disabled: true
                        )
                        
                        SecondaryChoiceCard(
                            title: "Grinder",
                            description: "Add a coffee grinder",
                            imageName: "grinder",
                            action: {
                                navigationCoordinator.addPath.append(AppDestination.addGrinder)
                            }
                        )
                    }
                    .opacity(showSecondaryChoices ? 1 : 0)
                    .offset(y: showSecondaryChoices ? 0 : 20)
                    
                } else if needsGrinder {
                    // Primary: Grinder
                    PrimaryChoiceCard(
                        title: "Add Grinder",
                        description: "Add your grinder to complete setup",
                        imageName: "grinder",
                        badgeText: "Almost Ready",
                        action: {
                            navigationCoordinator.addPath.append(AppDestination.addGrinder)
                        }
                    )
                    .opacity(showPrimaryChoice ? 1 : 0)
                    .offset(y: showPrimaryChoice ? 0 : 30)
                    
                    ORDivider()
                        .opacity(showSecondaryChoices ? 1 : 0)
                    
                    VStack(spacing: 12) {
                        SecondaryChoiceCard(
                            title: "Recipe",
                            description: "Add grinder first",
                            imageName: "v60.icon",
                            disabled: true
                        )
                        
                        SecondaryChoiceCard(
                            title: "Roaster",
                            description: "Add another roaster",
                            imageName: "roaster",
                            action: {
                                navigationCoordinator.addPath.append(AppDestination.addRoaster)
                            }
                        )
                    }
                    .opacity(showSecondaryChoices ? 1 : 0)
                    .offset(y: showSecondaryChoices ? 0 : 20)
                    
                } else {
                    // Primary: Recipe (most common choice)
                    PrimaryChoiceCard(
                        title: "Create Recipe",
                        description: "Start brewing with a new recipe",
                        imageName: "v60.icon",
                        badgeText: "",
                        action: {
                            navigationCoordinator.addPath.append(AppDestination.addRecipe(roaster: navigationCoordinator.selectedRoaster, grinder: navigationCoordinator.selectedGrinder))
                        }
                    )
                    .opacity(showPrimaryChoice ? 1 : 0)
                    .offset(y: showPrimaryChoice ? 0 : 30)
                    
                    ORDivider()
                        .opacity(showSecondaryChoices ? 1 : 0)
                    
                    VStack(spacing: 12) {
                        SecondaryChoiceCard(
                            title: "Roaster",
                            description: "Add a coffee roaster",
                            imageName: "roaster",
                            action: {
                                navigationCoordinator.addPath.append(AppDestination.addRoaster)
                            }
                        )
                        
                        SecondaryChoiceCard(
                            title: "Grinder",
                            description: "Add a coffee grinder",
                            imageName: "grinder",
                            action: {
                                navigationCoordinator.addPath.append(AppDestination.addGrinder)
                            }
                        )
                    }
                    .opacity(showSecondaryChoices ? 1 : 0)
                    .offset(y: showSecondaryChoices ? 0 : 20)
                }
            }
            
            
            Spacer()
        }
        .padding(.top, 24)
        .padding(.horizontal, 20)
        .background(BrewerColors.background)
        .onAppear {
            loadCounts()
            
            // Clear selectedGrinder when showing AddChoice normally
            if navigationCoordinator.addPath.isEmpty {
                navigationCoordinator.selectedGrinder = nil
            }
            
            // Staggered entrance animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showPrimaryChoice = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                showSecondaryChoices = true
            }
        }
    }
    
    private func loadCounts() {
        let roasterRequest: NSFetchRequest<Roaster> = Roaster.fetchRequest()
        let grinderRequest: NSFetchRequest<Grinder> = Grinder.fetchRequest()
        let recipeRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        
        do {
            roasterCount = try viewContext.count(for: roasterRequest)
            grinderCount = try viewContext.count(for: grinderRequest)
            recipeCount = try viewContext.count(for: recipeRequest)
        } catch {
            print("Error loading counts: \(error)")
        }
    }
}

// MARK: - Primary Choice Card
struct PrimaryChoiceCard: View {
    let title: String
    let description: String
    let imageName: String
    let badgeText: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
                    
                    SVGIcon(imageName, size: 40, color: BrewerColors.cream)
                }
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(BrewerColors.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 16))
                        .foregroundColor(BrewerColors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                        Text(badgeText)
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
                ZStack {
                    // Base background
                    BrewerColors.surface
                    
                    // Premium gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [
                            BrewerColors.caramel.opacity(0.15),
                            BrewerColors.caramel.opacity(0.05),
                            Color.clear,
                            BrewerColors.cream.opacity(0.03)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Subtle radial gradient for depth
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.08),
                            Color.clear
                        ]),
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: 200
                    )
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(BrewerColors.caramel.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: BrewerColors.caramel.opacity(0.15), radius: 20, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.3), radius: 40, x: 0, y: 20)
        }
        .buttonStyle(ImprovedScaleButtonStyle())
    }
}

// MARK: - Secondary Choice Card
struct SecondaryChoiceCard: View {
    let title: String
    let description: String
    let imageName: String
    let disabled: Bool
    let action: (() -> Void)?
    
    init(title: String, description: String, imageName: String, disabled: Bool = false, action: (() -> Void)? = nil) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.disabled = disabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if !disabled {
                action?()
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(disabled ? BrewerColors.surface.opacity(0.5) : BrewerColors.surface)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .strokeBorder(disabled ? BrewerColors.divider.opacity(0.5) : BrewerColors.divider, lineWidth: 1.5)
                        )
                    
                    SVGIcon(imageName, size: 24, color: disabled ? BrewerColors.textSecondary.opacity(0.5) : BrewerColors.cream)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(disabled ? BrewerColors.textSecondary.opacity(0.5) : BrewerColors.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(disabled ? BrewerColors.textSecondary.opacity(0.3) : BrewerColors.textSecondary)
                }
                
                Spacer()
                
                if !disabled {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(BrewerColors.textSecondary)
                }
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    disabled ? BrewerColors.cardBackground.opacity(0.3) : BrewerColors.cardBackground,
                                    disabled ? BrewerColors.cardBackground.opacity(0.2) : BrewerColors.cardBackground.opacity(0.9),
                                    disabled ? BrewerColors.caramel.opacity(0.03) : BrewerColors.caramel.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    disabled ? Color.white.opacity(0.02) : Color.white.opacity(0.1),
                                    disabled ? Color.white.opacity(0.01) : Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: disabled ? Color.clear : Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
            )
        }
        .disabled(disabled)
        .buttonStyle(ImprovedScaleButtonStyle())
    }
}

// MARK: - Guidance Card
struct GuidanceCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 20))
                .foregroundColor(BrewerColors.caramel)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Setup Guide")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(BrewerColors.textPrimary)
                
                Text("Complete your setup to start brewing recipes")
                    .font(.system(size: 14))
                    .foregroundColor(BrewerColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(BrewerColors.caramel.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(BrewerColors.caramel.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - OR Divider
struct ORDivider: View {
    var body: some View {
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
    }
}

// MARK: - Quick Stats Bar
struct QuickStatsBar: View {
    let roasterCount: Int
    let grinderCount: Int
    let recipeCount: Int
    
    var body: some View {
        HStack(spacing: 20) {
            StatBadge(count: roasterCount, label: "Roasters")
            StatBadge(count: grinderCount, label: "Grinders")
            StatBadge(count: recipeCount, label: "Recipes")
        }
        .padding(.horizontal, 18)
    }
}

struct StatBadge: View {
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(BrewerColors.caramel)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(BrewerColors.surface.opacity(0.5))
        )
    }
}

// MARK: - Scale Button Style
struct ImprovedScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonPressAnimation(isPressed: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var navigationCoordinator = NavigationCoordinator()
    
    GlobalBackground {
        AddChoice(navigationCoordinator: navigationCoordinator)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
