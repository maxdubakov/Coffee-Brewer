import SwiftUI

struct AddButton: BrewerButton {
    var title: String
    var action: () -> Void
    var maxWidth: CGFloat? = .infinity
    var iconName: String = "plus.circle.fill"
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [BrewerColors.espresso, BrewerColors.caramel]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        ZStack {
                            Circle()
                                .strokeBorder(BrewerColors.caramel, lineWidth: 1.5)
                            
                            // Plus symbol
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: BrewerColors.buttonShadow, radius: 4, x: 0, y: 2)
                
                Text(title)
                    .fontWeight(.medium)
                Spacer()
            }
        }
        .buttonStyle(AddButtonStyle(maxWidth: maxWidth))
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
