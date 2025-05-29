import SwiftUI

struct StatPill: View {
    var title: String
    var icon: String
    var color: Color = BrewerColors.caramel
    var size: StatPillSize = .small
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: size.fontSize))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: size.fontSize, weight: .medium))
                .foregroundColor(BrewerColors.textPrimary)
                .lineLimit(1)
        }
        .padding(.horizontal, size.paddingHorizontal)
        .padding(.vertical, size.paddingVertical)
        .background(Color(red: 0.15, green: 0.13, blue: 0.11))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(color.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

enum StatPillSize {
    case small
    case normal
    case large
    
    var paddingHorizontal: CGFloat {
        switch self {
        case .small: return 7
        case .normal: return 10
        case .large: return 13
        }
    }
    
    var paddingVertical: CGFloat {
        switch self {
        case .small: return 4
        case .normal: return 5
        case .large: return 7
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 10
        case .normal: return 12
        case .large: return 16
        }
    }
}

#Preview {
    GlobalBackground {
        VStack(spacing: 40) {
            StatPill(
                title: "10",
                icon: "circle.grid.3x3",
                color: BrewerColors.caramel,
                size: .small,
            )
            
            StatPill(
                title: "10",
                icon: "circle.grid.3x3",
                color: BrewerColors.caramel,
                size: .normal,
            )
            
            StatPill(
                title: "10",
                icon: "circle.grid.3x3",
                color: BrewerColors.caramel,
                size: .large,
            )
        }
    }
}
