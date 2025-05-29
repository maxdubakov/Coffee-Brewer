import SwiftUI

struct FeaturedRecipeCard: View {
    let recipe: Recipe
    var onBrewTapped: () -> Void = {}
    var onEditTapped: () -> Void = {}
    
    @State private var isPressed = false
    @State private var showQuickActions = false
    
    private var pourCount: Int {
        return recipe.stagesArray.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Hero Image Section with Overlay
            ZStack(alignment: .bottom) {
                // Full-width V60 image with multiple gradient layers
                ZStack {
                    // Base image
                    Image("V60")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.7)
                        .frame(height: 340)
                    
                    // Multi-layer gradient for depth
                    VStack(spacing: 0) {
                        // Top fade for action buttons
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.5),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                        .frame(height: 100)
                        
                        Spacer()
                        
                        // Bottom gradient for text
                        LinearGradient(
                            colors: [
                                Color.clear,
                                BrewerColors.espresso.opacity(0.4),
                                BrewerColors.espresso.opacity(0.7),
                                BrewerColors.espresso.opacity(0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 200)
                    }
                    
                    // Subtle texture overlay
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    BrewerColors.mocha.opacity(0.1),
                                    BrewerColors.espresso.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.overlay)
                }
                
                // Content overlay
                VStack(alignment: .leading, spacing: 16) {
                    // Title and roaster
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.name ?? "Untitled Recipe")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                        
                        if let roaster = recipe.roaster {
                            HStack(spacing: 6) {
                                if let country = roaster.country {
                                    Text(country.flag ?? "")
                                        .font(.title3)
                                }
                                Text(roaster.name ?? "")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                        }
                    }
                    
                    // Stats row
                    HStack(spacing: 12) {
                        // Coffee amount
                        HStack(spacing: 4) {
                            Image(systemName: "scalemass")
                                .font(.system(size: 12))
                            Text("\(recipe.grams)g")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        
                        Text("•")
                            .font(.system(size: 8))
                            .opacity(0.6)
                        
                        // Water amount
                        HStack(spacing: 4) {
                            Image(systemName: "drop")
                                .font(.system(size: 12))
                            Text("\(recipe.waterAmount)ml")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        
                        Text("•")
                            .font(.system(size: 8))
                            .opacity(0.6)
                        
                        // Ratio
                        Text("1:\(Int(recipe.ratio))")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        
                        Spacer()
                        
                        // Pour count
                        Text.pluralized("pour", count: pourCount)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 340)
            .clipped()
            
            // Bottom info bar
            HStack(spacing: 16) {
                // Grinder info
                if let grinder = recipe.grinder {
                    HStack(spacing: 6) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 12))
                            .foregroundColor(BrewerColors.caramel)
                        Text(grinder.name ?? "")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(BrewerColors.textPrimary)
                    }
                }
                
                // Grind size
                HStack(spacing: 6) {
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.system(size: 12))
                        .foregroundColor(BrewerColors.caramel)
                    Text("Grind \(recipe.grindSize)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(BrewerColors.textPrimary)
                }
                
                Spacer()
                
                // Last brew time
                HStack(spacing: 4) {
                    Circle()
                        .fill(BrewerColors.caramel)
                        .frame(width: 6, height: 6)
                    
                    Text((recipe.lastBrewedAt ?? Date()).timeAgoDescription())
                        .font(.system(size: 13))
                        .foregroundColor(BrewerColors.textSecondary)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                LinearGradient(
                    colors: [
                        BrewerColors.cardBackground,
                        BrewerColors.cardBackground.opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .background(
            ZStack {
                // Base background
                RoundedRectangle(cornerRadius: 20)
                    .fill(BrewerColors.cardBackground)
                
                // Premium border
                RoundedRectangle(cornerRadius: 20)
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
        )
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)
        .shadow(color: BrewerColors.espresso.opacity(0.2), radius: 24, x: 0, y: 12)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            isPressed = true
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                onBrewTapped()
            }
        }
    }
}

// MARK: - Preview
struct FeaturedRecipeCard_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let recipe = Recipe(context: context)
        recipe.id = UUID()
        recipe.name = "Ethiopian Natural Process"
        recipe.grams = 18
        recipe.ratio = 16.0
        recipe.waterAmount = 288
        recipe.grindSize = 24
        recipe.lastBrewedAt = Date().addingTimeInterval(-3600)
        
        let roaster = Roaster(context: context)
        roaster.id = UUID()
        roaster.name = "Tim Wendelboe"
        
        let country = Country(context: context)
        country.id = UUID()
        country.name = "Norway"
        country.flag = "🇳🇴"
        roaster.country = country
        
        recipe.roaster = roaster
        
        let grinder = Grinder(context: context)
        grinder.id = UUID()
        grinder.name = "Comandante C40"
        recipe.grinder = grinder
        
        // Add stages
        for i in 0..<4 {
            let stage = Stage(context: context)
            stage.id = UUID()
            stage.orderIndex = Int16(i)
            stage.recipe = recipe
        }
        
        return GlobalBackground {
            ScrollView {
                VStack(spacing: 20) {
                    FeaturedRecipeCard(recipe: recipe)
                        .padding(.horizontal, 20)
                }
                .padding(.vertical)
            }
        }
    }
}
