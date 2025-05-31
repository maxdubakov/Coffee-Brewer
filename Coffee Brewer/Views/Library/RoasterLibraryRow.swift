import SwiftUI
import CoreData

struct RoasterLibraryRow: View {
    let roaster: Roaster
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
                
                // Roaster icon
                SVGIcon("roaster", size: 24, color: BrewerColors.caramel)
                
                // Roaster Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(roaster.name ?? "Untitled Roaster")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(BrewerColors.cream)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        // Country flag
                        if let flag = roaster.country?.flag {
                            Text(flag)
                                .font(.system(size: 12))
                        }
                        
                        if let country = roaster.country {
                            Text(country.name ?? "")
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                                .lineLimit(1)
                        }
                        
                        // Show recipe count
                        if let recipes = roaster.recipes, recipes.count > 0 {
                            if roaster.country != nil {
                                Text("•")
                                    .font(.system(size: 9))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            }
                            
                            Text("\(recipes.count) recipe\(recipes.count == 1 ? "" : "s")")
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                        }
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
