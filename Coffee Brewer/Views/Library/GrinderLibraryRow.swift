import SwiftUI
import CoreData

struct GrinderLibraryRow: View {
    let grinder: Grinder
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
                
                // Grinder type icon
                Image(systemName: grinder.typeIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(BrewerColors.caramel)
                    .frame(width: 20, height: 20)
                
                // Grinder Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(grinder.name ?? "Untitled Grinder")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(BrewerColors.cream)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        if let type = grinder.type, !type.isEmpty {
                            Text(type)
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                                .lineLimit(1)
                        }
                        
                        if let burrType = grinder.burrType, !burrType.isEmpty {
                            if grinder.type != nil {
                                Text("•")
                                    .font(.system(size: 9))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            }
                            
                            Text(burrType)
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                                .lineLimit(1)
                        }
                        
                        if grinder.burrSize > 0 {
                            Text("•")
                                .font(.system(size: 9))
                                .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            
                            Text("\(grinder.burrSize)mm")
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                        }
                        
                        // Show recipe count
                        if let recipes = grinder.recipes, recipes.count > 0 {
                            Text("•")
                                .font(.system(size: 9))
                                .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            
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
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
