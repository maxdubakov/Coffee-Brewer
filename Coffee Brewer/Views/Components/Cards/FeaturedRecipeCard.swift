import SwiftUI

struct FeaturedRecipeCard: View {
    let recipe: Recipe
    var onBrewTapped: () -> Void = {}
    var onEditTapped: () -> Void = {}
    
    @State private var isPressed = false
    
    private var totalParts: Double {
        return 1.0 + recipe.ratio
    }
    
    private var coffeePercentage: Double {
        return (1.0 / totalParts) * 100
    }
    
    private var waterPercentage: Double {
        return (recipe.ratio / totalParts) * 100
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Image("V60")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 280)
                    .clipped()
                    .opacity(0.5)
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.5),
                        Color.black.opacity(0.8)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            
                            Text(recipe.name ?? "Untitled Recipe")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if let roaster = recipe.roaster {
                                HStack(spacing: 6) {
                                    if let country = roaster.country {
                                        Text(country.flag ?? "")
                                            .font(.title3)
                                    }
                                    Text(roaster.name ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            
                            Text((recipe.lastBrewedAt ?? Date()).timeAgoDescription())
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "scalemass")
                                    .font(.caption)
                                Text("\(recipe.grams)g")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 10)
                                    
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(red: 0.28, green: 0.16, blue: 0.08))
                                        .frame(width: geometry.size.width * CGFloat(coffeePercentage / 100), height: 10)
                                }
                            }
                            .frame(height: 4)
                        }
                        .frame(width: 100)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "drop.fill")
                                    .font(.caption)
                                Text("\(recipe.waterAmount)ml")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 10)
                                    
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(red: 0.20, green: 0.30, blue: 0.44))
                                        .frame(width: geometry.size.width * CGFloat(waterPercentage / 100), height: 10)
                                }
                            }
                            .frame(height: 4)
                        }
                        .frame(width: 100)
                    }
                }
                .padding(24)
            }
            
            HStack(spacing: 0) {
                HStack(spacing: 12) {
                    StatPill(
                        title: "\(recipe.grindSize)",
                        icon: "circle.grid.3x3",
                        color: BrewerColors.caramel,
                        size: .large
                    )
                    
                    StatPill(
                        title: "\(recipe.stagesArray.count) stage\(recipe.stagesArray.count == 1 ? "" : "s")",
                        icon: "drop",
                        color: BrewerColors.caramel,
                        size: .large
                    )
                    
                    if let grinder = recipe.grinder {
                        StatPill(
                            title: (grinder.name ?? "").components(separatedBy: " ").first ?? "",
                            icon: "gearshape.fill",
                            color: BrewerColors.textSecondary,
                            size: .large
                        )
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(BrewerColors.cardBackground)
        }
        .background(BrewerColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                onBrewTapped()
            }
        }
    }
}
