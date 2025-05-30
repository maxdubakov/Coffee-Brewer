import SwiftUI

struct FormColorPickerField: View {
    let title: String
    @Binding var selectedColor: String?
    
    private let chartColors: [(String, Color)] = [
        ("default", BrewerColors.espresso),                        // Rich espresso brown (default)
        ("caramel", BrewerColors.caramel),                          // Warm caramel brown
        ("ocean", Color(red: 0.13, green: 0.55, blue: 0.94)),       // Premium ocean blue
        ("forest", Color(red: 0.20, green: 0.67, blue: 0.53)),      // Sophisticated forest green  
        ("amber", Color(red: 0.96, green: 0.65, blue: 0.14)),       // Rich amber
        ("crimson", Color(red: 0.84, green: 0.23, blue: 0.31)),     // Deep crimson
        ("royal", Color(red: 0.45, green: 0.31, blue: 0.81)),       // Royal purple
        ("rose", Color(red: 0.91, green: 0.39, blue: 0.58)),        // Elegant rose
        ("copper", Color(red: 0.85, green: 0.52, blue: 0.31)),      // Warm copper
        ("lavender", Color(red: 0.61, green: 0.52, blue: 0.84))     // Soft lavender
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(BrewerColors.textPrimary)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                ForEach(chartColors, id: \.0) { colorName, color in
                    ColorOption(
                        color: color,
                        isSelected: selectedColor == colorName || (selectedColor == nil && colorName == "espresso"),
                        action: {
                            selectedColor = colorName == "espresso" ? nil : colorName
                        }
                    )
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ColorOption: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer glow ring for selected state
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: isSelected ? 50 : 40, height: isSelected ? 50 : 40)
                    .blur(radius: 2)
                    .opacity(isSelected ? 1 : 0)
                
                // Main color circle with subtle shadow
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                Color.white.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: color.opacity(0.3),
                        radius: isSelected ? 4 : 2,
                        x: 0,
                        y: isSelected ? 3 : 1
                    )
                
                // Selection indicator
                if isSelected {
                    Circle()
                        .strokeBorder(BrewerColors.background, lineWidth: 3)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .strokeBorder(color, lineWidth: 2)
                                .frame(width: 44, height: 44)
                        )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// Color conversion helper
extension String {
    func toColor() -> Color {
        switch self {
        case "caramel": return BrewerColors.caramel
        case "ocean": return Color(red: 0.13, green: 0.55, blue: 0.94)
        case "forest": return Color(red: 0.20, green: 0.67, blue: 0.53)
        case "amber": return Color(red: 0.96, green: 0.65, blue: 0.14)
        case "crimson": return Color(red: 0.84, green: 0.23, blue: 0.31)
        case "royal": return Color(red: 0.45, green: 0.31, blue: 0.81)
        case "rose": return Color(red: 0.91, green: 0.39, blue: 0.58)
        case "copper": return Color(red: 0.85, green: 0.52, blue: 0.31)
        case "lavender": return Color(red: 0.61, green: 0.52, blue: 0.84)
        default: return BrewerColors.espresso
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedColor: String? = nil
        
        var body: some View {
            GlobalBackground {
                VStack(spacing: 40) {
                    FormGroup {
                        FormColorPickerField(
                            title: "Chart Color",
                            selectedColor: $selectedColor
                        )
                    }
                    
                    if let color = selectedColor {
                        Text("Selected: \(color)")
                            .foregroundColor(BrewerColors.textSecondary)
                    } else {
                        Text("Selected: default")
                            .foregroundColor(BrewerColors.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
