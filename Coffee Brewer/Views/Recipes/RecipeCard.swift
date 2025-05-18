import SwiftUI

struct RecipeCard: View {
    // MARK: - Public Properties
    let recipe: Recipe
    var onBrewTapped: () -> Void = {}
    var onEditTapped: () -> Void = {}
    var onDeleteTapped: () -> Void = {}
    
    @State private var showMenu: Bool = false
    
    private var stageCount: Int {
        return recipe.stagesArray.count
    }
    
    // MARK: - Size Calculations
    // Constants
    private let maxBarWidth: CGFloat = 160
    private let minBarWidth: CGFloat = 50
    
    private var totalParts: Double {
        return 1.0 + recipe.ratio // 1 part coffee + X parts water
    }
    
    private var coffeeBarWidth: CGFloat {
        let proportionalWidth = maxBarWidth * (1.0 / totalParts)
        return max(proportionalWidth, minBarWidth)
    }
    
    private var waterBarWidth: CGFloat {
        let proportionalWidth = maxBarWidth * (recipe.ratio / totalParts)
        return max(proportionalWidth, minBarWidth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image with overlaid visualizations
            ZStack(alignment: .topLeading) {
                // Base image
                Image("V60")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 169)
                    .clipped()
                
                // Dark overlay at the bottom of the image for better text visibility
                VStack {
                    Spacer()
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color.black.opacity(0),
                                Color.black.opacity(0.7)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 70)
                }
                
                // Recipe Visualizations overlay (positioned at bottom of image)
                VStack(alignment: .leading, spacing: 6) {
                    Spacer()
                    
                    // Coffee visualization
                    ZStack(alignment: .leading) {
                        // Background bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.28, green: 0.16, blue: 0.08))
                            .frame(width: coffeeBarWidth, height: 22)
                            .opacity(0.9)
                        
                        // Text overlay
                        HStack(spacing: 4) {
                            Image(systemName: "scalemass")
                                .font(.system(size: 10))
                            Text("\(recipe.grams)g")
                                .font(.system(size: 10, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                    }
                    
                    // Water amount visual
                    ZStack(alignment: .leading) {
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.20, green: 0.30, blue: 0.44))
                            .frame(width: waterBarWidth, height: 22)
                            .opacity(0.9)
                        
                        // Water amount text
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 10))
                            Text("\(recipe.waterAmount)ml")
                                .font(.system(size: 10, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                    }
                    
                    Spacer()
                        .frame(height: 4)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            
            // Recipe Details section
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(recipe.name ?? "Untitled Recipe")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BrewerColors.textPrimary)
                    .frame(minWidth: 99, alignment: .leading)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 150, alignment: .leading)
                
                // Last brewed time
                Text((recipe.lastBrewedAt ?? Date()).timeAgoDescription())
                    .font(.caption)
                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                    .frame(minWidth: 99, alignment: .leading)
                
                // Quick stats pills
                HStack(spacing: 6) {
                    // Grind size pill
                    StatPill(
                        title: "\(recipe.grindSize)",
                        icon: "circle.grid.3x3",
                        color: BrewerColors.caramel
                    )
                    
                    // Number of stages pill
                    StatPill(
                        title: "\(stageCount) stage\(stageCount == 1 ? "" : "s")",
                        icon: "drop",
                        color: BrewerColors.caramel
                    )
                }
                .padding(.top, 6)
            }
            .padding(14)
            .background(
                BrewerColors.cardBackground
            )
        }
        .background(BrewerColors.cardBackground)
        .cornerRadius(12)
        .contextMenu {
            Button(action: onBrewTapped) {
                Label("Brew", systemImage: "mug")
            }
            
            Button(action: onEditTapped) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: onDeleteTapped) {
                Label("Delete", systemImage: "trash")
                    .foregroundColor(Color.red)
            }
        }
    }
}

// MARK: - Preview
struct RecipeCardPreview: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Create test recipes with different characteristics
        func createRecipe(name: String, roasterName: String, grams: Int16, ratio: Double, grindSize: Int16) -> Recipe {
            let recipe = Recipe(context: context)
            recipe.name = name
            recipe.grams = grams
            recipe.ratio = ratio
            recipe.waterAmount = Int16(Double(grams) * ratio)
            recipe.grindSize = grindSize
            recipe.lastBrewedAt = Date().addingTimeInterval(-86400 * Double.random(in: 0...7))
            
            // Create a roaster
            let roaster = Roaster(context: context)
            roaster.name = roasterName
            recipe.roaster = roaster
            
            return recipe
        }
        
        // Create sample stages for a recipe
        func addStages(to recipe: Recipe, types: [(String, Int16, Int16)]) {
            for (index, stageInfo) in types.enumerated() {
                let stage = Stage(context: context)
                stage.type = stageInfo.0
                stage.waterAmount = stageInfo.1
                stage.seconds = stageInfo.2
                stage.orderIndex = Int16(index)
                stage.recipe = recipe
            }
        }
        
        // Create some different recipe examples
        let espresso = createRecipe(name: "Dark Espresso", roasterName: "Italian Roasters", grams: 18, ratio: 2.5, grindSize: 8)
        addStages(to: espresso, types: [("slow", 45, 30)])
        
        let pourOver = createRecipe(name: "Ethiopian Pour Over", roasterName: "Ethio Coffee Co.", grams: 20, ratio: 16.0, grindSize: 32)
        addStages(to: pourOver, types: [("fast", 60, 10), ("wait", 0, 30), ("slow", 140, 60), ("fast", 120, 20)])
        
        let aeroPressRecipe = createRecipe(name: "AeroPress Light", roasterName: "Nordic Coffee", grams: 15, ratio: 13.0, grindSize: 20)
        addStages(to: aeroPressRecipe, types: [("fast", 195, 10), ("wait", 0, 90)])
        
        return GlobalBackground {
            VStack(spacing: 20) {
                Text("Recipe Cards")
                    .font(.title)
                    .foregroundColor(BrewerColors.textPrimary)
                
                HStack(spacing: 16) {
                    RecipeCard(recipe: espresso)
                    RecipeCard(recipe: pourOver)
                }
                
                RecipeCard(recipe: aeroPressRecipe)
            }
            .padding()
        }
    }
}
