import SwiftUI
import CoreData

struct BrewLibraryRow: View {
    let brew: Brew
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
                
                // Brew icon with circular background
                ZStack {
                    Circle()
                        .fill(BrewerColors.caramel.opacity(0.12))
                        .overlay(
                            Circle()
                                .strokeBorder(BrewerColors.caramel.opacity(0.2), lineWidth: 1)
                        )
                        .frame(width: 44, height: 44)
                    
                    SVGIcon("coffee.beans", size: 24, color: BrewerColors.caramel)
                }
                
                // Brew Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(brew.name ?? brew.recipeName ?? "Untitled Brew")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(BrewerColors.cream)
                        .lineLimit(1)
                    
                    HStack(spacing: 6) {
                        if let date = brew.date {
                            Text(date, style: .date)
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                        }
                        
                        if brew.rating > 0 {
                            Text("•")
                                .font(.system(size: 9))
                                .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            
                            HStack(spacing: 2) {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(brew.rating) ? "star.fill" : "star")
                                        .font(.system(size: 9))
                                        .foregroundColor(index < Int(brew.rating) ? BrewerColors.caramel : BrewerColors.textSecondary.opacity(0.3))
                                }
                            }
                        }
                        
                        if let roasterName = brew.roasterName {
                            Text("•")
                                .font(.system(size: 9))
                                .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            
                            Text(roasterName)
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                                .lineLimit(1)
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