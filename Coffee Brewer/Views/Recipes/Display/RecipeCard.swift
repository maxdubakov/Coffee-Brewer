import SwiftUI

struct RecipeCard: View {
    // MARK: - Public Properties
    let recipe: Recipe
    var onBrewTapped: () -> Void = {}
    var onEditTapped: () -> Void = {}
    var onDeleteTapped: () -> Void = {}
    var onDuplicateTapped: () -> Void = {}
    
    @State private var isPressed = false
    @State private var showQuickActions = false
    @State private var showRoasterDetail = false
    @State private var showGrinderDetail = false
    
    private var pourCount: Int {
        return recipe.stagesArray.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Premium Image Section with Info Overlay
            ZStack(alignment: .bottom) {
                // V60 Image with gradient overlays
                ZStack {
                    // Base V60 image
                    Image("V60")
                        .resizable()
                        .scaledToFill()
                    
                    // Gradient overlays for depth and readability
                    VStack(spacing: 0) {
                        // Top subtle gradient
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                        .frame(height: 60)
                        
                        Spacer()
                        
                        // Bottom strong gradient for text readability
                        LinearGradient(
                            colors: [
                                Color.clear,
                                BrewerColors.espresso.opacity(0.6),
                                BrewerColors.espresso.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 100)
                    }
                }
                
                // Info overlay on image
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        HStack(spacing: 3) {
                            Text("\(recipe.grams)g")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        
                        Text("•")
                            .font(.system(size: 8))
                            .opacity(0.6)
                        
                        HStack(spacing: 3) {
                            Text("\(recipe.waterAmount)ml")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        
                        Text("•")
                            .font(.system(size: 8))
                            .opacity(0.6)
                        
                        Text("1:\(Int(recipe.grindSize))")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white)
                }
                .padding(.bottom, 10)
            }
            
            // Compact Details Section
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    // Title and Roaster
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.name ?? "Untitled Recipe")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(BrewerColors.cream)
                            .lineLimit(1)
                        
                        // Roaster info
                        if let roaster = recipe.roaster {
                            HStack(spacing: 4) {
                                if let country = roaster.country {
                                    Text(country.flag ?? "")
                                        .font(.caption2)
                                }
                                Text(roaster.name ?? "")
                                    .font(.caption2)
                                    .foregroundColor(BrewerColors.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    // Time since last brew
                    HStack(spacing: 4) {
                        Circle()
                            .fill(BrewerColors.caramel.opacity(0.4))
                            .frame(width: 5, height: 5)
                        
                        Text((recipe.lastBrewedAt ?? Date()).timeAgoDescription())
                            .font(.system(size: 10))
                            .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                    }
                }
                .padding(12)
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
                Spacer()
            }
        }
        .background(
            ZStack {
                // Base background
                RoundedRectangle(cornerRadius: 16)
                    .fill(BrewerColors.cardBackground)
                
                // Subtle border
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .shadow(color: BrewerColors.espresso.opacity(0.1), radius: 16, x: 0, y: 8)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            isPressed = true
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                onBrewTapped()
            }
        }
        .contextMenu {
            Button(action: onBrewTapped) {
                Label("Brew", systemImage: "mug")
            }
            
            Button(action: onEditTapped) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: onDuplicateTapped) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            
            Divider()
            
            if recipe.roaster != nil {
                Button(action: { showRoasterDetail = true }) {
                    Label("Roaster", systemImage: "building.2")
                }
            }
            
            if recipe.grinder != nil {
                Button(action: { showGrinderDetail = true }) {
                    Label("Grinder", systemImage: "gearshape")
                }
            }
            
            Divider()
            
            Button(action: onDeleteTapped) {
                Label("Delete", systemImage: "trash")
                    .foregroundColor(Color.red)
            }
        }
        .overlay(alignment: .topTrailing) {
            if showQuickActions {
                HStack(spacing: 8) {
                    Button(action: {
                        showQuickActions = false
                        onEditTapped()
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12))
                            .foregroundColor(BrewerColors.cream)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(BrewerColors.mocha))
                    }
                    
                    Button(action: {
                        showQuickActions = false
                        onBrewTapped()
                    }) {
                        Image(systemName: "mug")
                            .font(.system(size: 12))
                            .foregroundColor(BrewerColors.cream)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(BrewerColors.espresso))
                    }
                }
                .padding(10)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showQuickActions)
        .sheet(isPresented: $showRoasterDetail) {
            if let roaster = recipe.roaster {
                RoasterDetailSheet(roaster: roaster)
                    .presentationDetents([.height(400)])
                    .presentationDragIndicator(.hidden)
            }
        }
        .sheet(isPresented: $showGrinderDetail) {
            if let grinder = recipe.grinder {
                GrinderDetailSheet(grinder: grinder)
                    .presentationDetents([.height(400)])
                    .presentationDragIndicator(.hidden)
            }
        }
    }
}

// MARK: - Preview
struct PremiumRecipeCardPreview: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        // Create test recipes with different characteristics
        func createRecipe(name: String, roasterName: String, countryFlag: String, grams: Int16, ratio: Double, grindSize: Int16) -> Recipe {
            let recipe = Recipe(context: context)
            recipe.id = UUID()
            recipe.name = name
            recipe.grams = grams
            recipe.ratio = ratio
            recipe.waterAmount = Int16(Double(grams) * ratio)
            recipe.grindSize = grindSize
            recipe.lastBrewedAt = Date().addingTimeInterval(-86400 * Double.random(in: 0...7))
            
            // Create a roaster with country
            let roaster = Roaster(context: context)
            roaster.id = UUID()
            roaster.name = roasterName
            
            // Create country
            let country = Country(context: context)
            country.id = UUID()
            country.name = roasterName
            country.flag = countryFlag
            roaster.country = country
            
            recipe.roaster = roaster
            
            // Create grinder
            let grinder = Grinder(context: context)
            grinder.id = UUID()
            grinder.name = "Comandante C40"
            recipe.grinder = grinder
            
            return recipe
        }
        
        // Create sample stages for a recipe
        func addStages(to recipe: Recipe, types: [(String, Int16, Int16)]) {
            for (index, stageInfo) in types.enumerated() {
                let stage = Stage(context: context)
                stage.id = UUID()
                stage.type = stageInfo.0
                stage.waterAmount = stageInfo.1
                stage.seconds = stageInfo.2
                stage.orderIndex = Int16(index)
                stage.recipe = recipe
            }
        }
        
        // Create different recipe examples
        let espresso = createRecipe(
            name: "Morning Espresso",
            roasterName: "La Cabra",
            countryFlag: "🇩🇰",
            grams: 18,
            ratio: 2.5,
            grindSize: 8
        )
        addStages(to: espresso, types: [("slow", 45, 30)])
        
        let pourOver = createRecipe(
            name: "Ethiopian Natural",
            roasterName: "Tim Wendelboe",
            countryFlag: "🇳🇴",
            grams: 20,
            ratio: 16.0,
            grindSize: 28
        )
        addStages(to: pourOver, types: [("fast", 60, 10), ("wait", 0, 30), ("slow", 140, 60), ("fast", 120, 20)])
        
        let aeropress = createRecipe(
            name: "Inverted AeroPress",
            roasterName: "Blue Bottle",
            countryFlag: "🇺🇸",
            grams: 15,
            ratio: 11.0,
            grindSize: 18
        )
        addStages(to: aeropress, types: [("fast", 165, 10), ("wait", 0, 90)])
        
        return GlobalBackground {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Premium Recipe Cards")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(BrewerColors.cream)
                    
                    ForEach([espresso, pourOver, aeropress]) { recipe in
                        RecipeCard(recipe: recipe)
                    }
                    
                    // Horizontal scroll example
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Horizontal Scroll")
                            .font(.headline)
                            .foregroundColor(BrewerColors.textPrimary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach([espresso, pourOver, aeropress]) { recipe in
                                    RecipeCard(recipe: recipe)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
    }
}
