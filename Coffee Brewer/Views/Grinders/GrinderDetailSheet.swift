import SwiftUI

struct GrinderDetailSheet: View {
    let grinder: Grinder
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest private var recipes: FetchedResults<Recipe>
    
    init(grinder: Grinder) {
        self.grinder = grinder
        self._recipes = FetchRequest(
            entity: Recipe.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.lastBrewedAt, ascending: false)],
            predicate: NSPredicate(format: "grinder == %@", grinder),
            animation: .default
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main grinder card
            VStack(spacing: 0) {
                // Header section with icon and name
                VStack(spacing: 20) {
                    // Top: Icon and name horizontally aligned
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: grinder.typeIcon)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(BrewerColors.caramel)
                        }
                        
                        Text(grinder.name ?? "Unknown Grinder")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(BrewerColors.cream)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                    
                    // Bottom: Burr size and last used info aligned left
                    HStack(spacing: 32) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Burr Size")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                            
                            Text("\(grinder.burrSize)mm")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(BrewerColors.cream)
                        }
                        
                        if let lastBrew = recipes.first?.lastBrewedAt {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last Used")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                                
                                Text(lastBrew.timeAgoDescription())
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(BrewerColors.cream)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 20)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [
                                    BrewerColors.cardBackground,
                                    BrewerColors.cardBackground.opacity(0.9),
                                    BrewerColors.espresso.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
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
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Recent recipes section
            if !recipes.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recent Recipes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(BrewerColors.cream)
                        Spacer()
                        Text("\(recipes.count)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(BrewerColors.caramel)
                    }
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(recipes.prefix(4)) { recipe in
                                HStack(spacing: 16) {
                                    // Recipe indicator dot
                                    Circle()
                                        .fill(BrewerColors.caramel)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 2)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(recipe.name ?? "Untitled")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(BrewerColors.cream)
                                            .lineLimit(1)
                                        
                                        HStack(spacing: 12) {
                                            Text("Grind \(recipe.grindSize)")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(BrewerColors.textSecondary)
                                            
                                            Text("•")
                                                .font(.system(size: 8))
                                                .foregroundColor(BrewerColors.textSecondary.opacity(0.6))
                                            
                                            Text("\(recipe.grams)g")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(BrewerColors.textSecondary)
                                            
                                            Spacer()
                                            
                                            if let lastBrew = recipe.lastBrewedAt {
                                                Text(lastBrew.timeAgoDescription())
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .frame(maxHeight: 160)
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
            }
            Spacer()
        }
        .background(BrewerColors.background.ignoresSafeArea())
    }
    
    private var averageGrindSize: Double? {
        guard !recipes.isEmpty else { return nil }
        let total = recipes.reduce(0) { $0 + Double($1.grindSize) }
        return total / Double(recipes.count)
    }
}
