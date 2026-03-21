import SwiftUI
import CoreData

struct CoffeeLibraryRow: View {
    let coffee: Coffee
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

                // Coffee icon with circular background
                ZStack {
                    Circle()
                        .fill(BrewerColors.caramel.opacity(0.12))
                        .overlay(
                            Circle()
                                .strokeBorder(BrewerColors.caramel.opacity(0.2), lineWidth: 1)
                        )
                        .frame(width: 44, height: 44)

                    SVGIcon("coffee.bag", size: 24, color: BrewerColors.caramel)
                }

                // Coffee Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(coffee.displayName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(BrewerColors.cream)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        // Roaster name
                        if let roasterName = coffee.roaster?.name {
                            Text(roasterName)
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                                .lineLimit(1)
                        }

                        // Process
                        if let process = coffee.process, !process.isEmpty {
                            if coffee.roaster != nil {
                                Text("•")
                                    .font(.system(size: 9))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            }
                            Text(process)
                                .font(.system(size: 12))
                                .foregroundColor(BrewerColors.textSecondary)
                                .lineLimit(1)
                        }

                        // Brew count
                        if coffee.brewCount > 0 {
                            let hasPrefix = coffee.roaster != nil || !(coffee.process ?? "").isEmpty
                            if hasPrefix {
                                Text("•")
                                    .font(.system(size: 9))
                                    .foregroundColor(BrewerColors.textSecondary.opacity(0.4))
                            }
                            Text("\(coffee.brewCount) brew\(coffee.brewCount == 1 ? "" : "s")")
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
