import SwiftUI

// MARK: - Stage Card Base View
struct StageCard<Content: View, Trailing: View>: View {
    let stageNumber: Int
    let stageType: StageType
    var size: StageCardSize = .normal
    var showBorder: Bool = true
    let content: () -> Content
    let trailing: () -> Trailing
    
    init(stageNumber: Int, stageType: StageType, size: StageCardSize = .normal, showBorder: Bool = true, @ViewBuilder content: @escaping () -> Content, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.stageNumber = stageNumber
        self.stageType = stageType
        self.size = size
        self.showBorder = showBorder
        self.content = content
        self.trailing = trailing
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Stage number circle
            StageNumberCircle(
                number: stageNumber,
                color: stageType.color,
                size: size
            )
            
            // Custom content
            content()
            
            Spacer(minLength: 0)

            // Trailing content inside the card
            trailing()
        }
        .padding(.vertical, size.verticalPadding)
        .padding(.leading, size.horizontalPadding)
        .padding(.trailing, size.trailingPadding)
        .background(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(BrewerColors.surface.opacity(0.6))
                .overlay(
                    showBorder ? 
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .strokeBorder(stageType.color.opacity(0.2), lineWidth: 1) : nil
                )
        )
    }
}

// MARK: - Stage Card with String Type
struct StageCardString<Content: View, Trailing: View>: View {
    let stageNumber: Int
    let stageType: String
    var size: StageCardSize = .normal
    var showBorder: Bool = true
    let content: () -> Content
    let trailing: () -> Trailing
    
    init(stageNumber: Int, stageType: String, size: StageCardSize = .normal, showBorder: Bool = true, @ViewBuilder content: @escaping () -> Content, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.stageNumber = stageNumber
        self.stageType = stageType
        self.size = size
        self.showBorder = showBorder
        self.content = content
        self.trailing = trailing
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Stage number circle
            StageNumberCircle(
                number: stageNumber,
                color: stageType.stageColor,
                size: size
            )
            
            // Custom content
            content()
            
            Spacer(minLength: 0)

            // Trailing content inside the card
            trailing()
        }
        .padding(.vertical, size.verticalPadding)
        .padding(.leading, size.horizontalPadding)
        .padding(.trailing, size.trailingPadding)
        .background(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .fill(BrewerColors.surface.opacity(0.6))
                .overlay(
                    showBorder ? 
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .strokeBorder(stageType.stageColor.opacity(0.2), lineWidth: 1) : nil
                )
        )
    }
}

// MARK: - Stage Number Circle
struct StageNumberCircle: View {
    let number: Int
    let color: Color
    var size: StageCardSize = .normal
    
    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [BrewerColors.espresso, color.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .overlay(
                    Circle()
                        .strokeBorder(color, lineWidth: 1.5)
                )
                .frame(width: size.circleSize, height: size.circleSize)
                .shadow(color: BrewerColors.buttonShadow, radius: 4, x: 0, y: 2)
            
            Text("\(number)")
                .font(.system(size: size.numberFontSize, weight: .semibold))
                .foregroundColor(BrewerColors.cream)
        }
    }
}

// MARK: - Stage Info View
struct StageInfo: View {
    let icon: String
    let title: String
    let color: Color
    var iconSize: CGFloat = 14
    var titleSize: CGFloat = 17
    
    var body: some View {
        Text(title)
            .font(.system(size: titleSize, weight: .semibold))
            .foregroundColor(BrewerColors.textPrimary)
    }
}

// MARK: - Stage Card Size
enum StageCardSize {
    case small
    case normal
    case large
    
    var circleSize: CGFloat {
        switch self {
        case .small: return 35
        case .normal: return 40
        case .large: return 60
        }
    }
    
    var numberFontSize: CGFloat {
        switch self {
        case .small: return 14
        case .normal: return 16
        case .large: return 24
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small: return 10
        case .normal: return 12
        case .large: return 20
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 12
        case .normal: return 16
        case .large: return 16
        }
    }
    
    var trailingPadding: CGFloat {
        switch self {
        case .small: return 12
        case .normal: return 16
        case .large: return 20
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .small: return 12
        case .normal: return 14
        case .large: return 16
        }
    }
}
