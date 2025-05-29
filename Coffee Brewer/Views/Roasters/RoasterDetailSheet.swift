import SwiftUI

struct RoasterDetailSheet: View {
    let roaster: Roaster
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest private var recipes: FetchedResults<Recipe>
    
    init(roaster: Roaster) {
        self.roaster = roaster
        self._recipes = FetchRequest(
            entity: Recipe.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.lastBrewedAt, ascending: false)],
            predicate: NSPredicate(format: "roaster == %@", roaster),
            animation: .default
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main roaster card
            VStack(spacing: 0) {
                // Header section with flag and name
                VStack(spacing: 20) {
                    // Top: Flag and name horizontally aligned
                    HStack(spacing: 12) {
                        if let country = roaster.country {
                            Text(country.flag ?? "")
                                .font(.system(size: 32))
                        }
                        
                        Text(roaster.name ?? "Unknown Roaster")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(BrewerColors.cream)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                    
                    // Bottom: Country, founded year, and last brew info aligned left
                    HStack(spacing: 28) {
                        if let country = roaster.country {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Country")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                                
                                Text(country.name ?? "")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(BrewerColors.cream)
                            }
                        }
                        
                        if roaster.foundedYear > 0 {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Founded")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                                
                                Text("\(roaster.foundedYear)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(BrewerColors.cream)
                            }
                        }
                        
                        if let lastBrew = recipes.first?.lastBrewedAt {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Last Brew")
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
                                    BrewerColors.mocha.opacity(0.15)
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
                    Text("Recent Recipes")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                        .padding(.horizontal, 20)
                    
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
                                            Text("\(recipe.grams)g")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(BrewerColors.textSecondary)
                                            
                                            Text("•")
                                                .font(.system(size: 8))
                                                .foregroundColor(BrewerColors.textSecondary.opacity(0.6))
                                            
                                            Text("\(recipe.waterAmount)ml")
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
                                .padding(.horizontal, 20)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .frame(maxHeight: 160)
                }
                .padding(.top, 24)
            }
            
            Spacer()
        }
        .background(BrewerColors.background.ignoresSafeArea())
    }
}