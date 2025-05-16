import SwiftUI

struct StandardButton: BrewerButton {
    var title: String
    var action: () -> Void
    var maxWidth: CGFloat? = .infinity
    var style: ButtonStyleType
    
    // Different button style types
    enum ButtonStyleType {
        case primary
        case secondary
        case coffee
        case destructive
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .modifier(buttonStyleModifier)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // Use a ViewModifier instead of returning different ButtonStyle types
    private var buttonStyleModifier: some ViewModifier {
        ButtonStyleModifier(styleType: style, maxWidth: maxWidth)
    }
}

struct ExampleButtonsView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Using the direct button components
                    StandardButton(
                        title: "Order Now",
                        action: { print("Primary tapped") },
                        style: .primary
                    )
                    
                    StandardButton(
                        title: "View Menu",
                        action: { print("Secondary tapped") },
                        maxWidth: geometry.size.width / 2,
                        style: .secondary
                    )
                    
                    StandardButton(
                        title: "Premium Beans",
                        action: { print("Coffee tapped") },
                        maxWidth: 200,
                        style: .coffee
                    )
                    
                    AddButton(
                        title: "Add New Coffee",
                        action: { print("Add tapped") }
                    )
                    
                    StandardButton(
                        title: "Cancel Order",
                        action: { print("Destructive tapped") },
                        style: .destructive
                    )
                }
                .padding(24)
            }
        }
    }
}

#Preview {
    GlobalBackground {
        ExampleButtonsView()
    }
}
