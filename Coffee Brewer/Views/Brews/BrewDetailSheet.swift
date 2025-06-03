import SwiftUI

struct BrewDetailSheet: View {
    let brew: Brew
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Main brew card
            VStack(spacing: 0) {
                // Header section with brew info
                VStack(spacing: 20) {
                    // Top: Recipe name and rating
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(brew.recipeName ?? "Untitled Brew")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(BrewerColors.cream)
                                .lineLimit(2)
                            
                            if let roasterName = brew.roasterName {
                                Text(roasterName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        if brew.rating > 0 {
                            HStack(spacing: 4) {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(brew.rating) ? "star.fill" : "star")
                                        .font(.system(size: 16))
                                        .foregroundColor(index < Int(brew.rating) ? BrewerColors.caramel : BrewerColors.textSecondary.opacity(0.3))
                                }
                            }
                        }
                    }
                    
                    // Bottom: Brew date and key metrics
                    VStack(spacing: 16) {
                        HStack(spacing: 24) {
                            if let date = brew.date {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Brewed")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                                    
                                    Text(date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(BrewerColors.cream)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Duration")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                                
                                Text(formatTime(seconds: Int(brew.actualDurationSeconds)))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(BrewerColors.cream)
                            }
                            
                            if brew.tds > 0 {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("TDS")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(BrewerColors.textSecondary.opacity(0.8))
                                    
                                    Text(String(format: "%.2f%%", brew.tds))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(BrewerColors.cream)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Recipe parameters
                        HStack(spacing: 12) {
                            RecipeMetric(
                                iconName: "scalemass",
                                value: "\(brew.recipeGrams)g",
                                color: BrewerColors.caramel
                            )
                            .frame(maxWidth: 80)
                            
                            RecipeMetric(
                                iconName: "drop",
                                value: "\(brew.recipeWaterAmount)ml",
                                color: BrewerColors.caramel
                            )
                            .frame(maxWidth: 80)
                            
                            RecipeMetric(
                                iconName: "thermometer",
                                value: "\(Int(brew.recipeTemperature))°C",
                                color: BrewerColors.caramel
                            )
                            .frame(maxWidth: 80)
                            
                            RecipeMetric(
                                iconName: "circle.grid.3x3",
                                value: "Grind \(brew.recipeGrindSize)",
                                color: BrewerColors.caramel
                            )
                            .frame(maxWidth: 100)
                            
                            Spacer()
                        }
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
                                    BrewerColors.caramel.opacity(0.12)
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
            
            // Taste profile section
            if hasTasteProfile {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Taste Profile")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        TasteProfileRow(label: "Acidity", value: Int(brew.acidity))
                        TasteProfileRow(label: "Sweetness", value: Int(brew.sweetness))
                        TasteProfileRow(label: "Bitterness", value: Int(brew.bitterness))
                        TasteProfileRow(label: "Body", value: Int(brew.body))
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 24)
            }
            
            // Notes section
            if let notes = brew.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notes")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(BrewerColors.cream)
                        .padding(.horizontal, 20)
                    
                    Text(notes)
                        .font(.system(size: 15))
                        .foregroundColor(BrewerColors.textPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(BrewerColors.cardBackground.opacity(0.5))
                        )
                        .padding(.horizontal, 20)
                }
                .padding(.top, 24)
            }
            
            Spacer()
        }
        .background(BrewerColors.background.ignoresSafeArea())
    }
    
    private var hasTasteProfile: Bool {
        brew.acidity > 0 || brew.sweetness > 0 || brew.bitterness > 0 || brew.body > 0
    }
    
    private func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Taste Profile Row
private struct TasteProfileRow: View {
    let label: String
    let value: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(BrewerColors.textSecondary)
                .frame(width: 80, alignment: .leading)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(BrewerColors.divider)
                        .frame(height: 8)
                    
                    if value > 0 {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(BrewerColors.caramel)
                            .frame(width: geometry.size.width * CGFloat(value) / 10.0, height: 8)
                    }
                }
            }
            .frame(height: 8)
            
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(BrewerColors.cream)
                .frame(width: 20, alignment: .trailing)
        }
    }
}

// MARK: - Preview
#Preview {
    let context = PersistenceController.preview.container.viewContext
    
    let brew = Brew(context: context)
    brew.id = UUID()
    brew.recipeName = "Ethiopian Pour Over"
    brew.roasterName = "Blue Bottle Coffee"
    brew.date = Date()
    brew.rating = 4
    brew.actualDurationSeconds = 210
    brew.recipeGrams = 18
    brew.recipeWaterAmount = 250
    brew.recipeTemperature = 94
    brew.recipeGrindSize = 14
    brew.tds = 1.35
    brew.acidity = 7
    brew.sweetness = 8
    brew.bitterness = 3
    brew.body = 6
    brew.notes = "Wonderful fruity notes with hints of blueberry and chocolate. The acidity is bright but balanced, with a silky smooth body. This is exactly the profile I was hoping for with this Ethiopian coffee."
    
    return BrewDetailSheet(brew: brew)
}