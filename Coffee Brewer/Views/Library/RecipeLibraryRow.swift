
import SwiftUI
import CoreData

struct RecipeLibraryRow: View {
    let recipe: Recipe
    let isEditMode: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Selection circle (shown in edit mode)
                if isEditMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? BrewerColors.caramel : BrewerColors.textSecondary.opacity(0.4))
                        .animation(.easeInOut(duration: 0.2), value: isSelected)
                }
                
                // Recipe icon with circular background
                ZStack {
                    Circle()
                        .fill(BrewerColors.caramel.opacity(0.12))
                        .overlay(
                            Circle()
                                .strokeBorder(BrewerColors.caramel.opacity(0.2), lineWidth: 1)
                        )
                        .frame(width: 44, height: 44)
                    
                    SVGIcon(recipe.brewMethodEnum.iconName, size: 30, color: BrewerColors.caramel)
                }
                
                // Recipe Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(recipe.name ?? "Untitled Recipe")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(BrewerColors.cream)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        // Country flag
                        if let flag = recipe.roaster?.country?.flag {
                            Text(flag)
                                .font(.system(size: 12))
                        }
                        
                        if let roaster = recipe.roaster {
                            Text(roaster.name ?? "")
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                                .lineLimit(1)
                        }
                        
                        Text("•")
                            .font(.system(size: 9))
                            .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                        
                        Text("\(recipe.grams)g")
                            .font(.system(size: 12))
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Chevron (hidden in edit mode)
                if !isEditMode {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(BrewerColors.textSecondary.opacity(0.3))
                }
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
