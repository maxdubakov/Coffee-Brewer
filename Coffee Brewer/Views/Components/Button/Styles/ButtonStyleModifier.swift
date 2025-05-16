import SwiftUI

struct ButtonStyleModifier: ViewModifier {
    let styleType: StandardButton.ButtonStyleType
    let maxWidth: CGFloat?
    
    func body(content: Content) -> some View {
        switch styleType {
        case .primary:
            content.buttonStyle(PrimaryButtonStyle(maxWidth: maxWidth))
        case .secondary:
            content.buttonStyle(SecondaryButtonStyle(maxWidth: maxWidth))
        case .coffee:
            content.buttonStyle(CoffeeButtonStyle(maxWidth: maxWidth))
        case .destructive:
            content.buttonStyle(DestructiveButtonStyle(maxWidth: maxWidth))
        }
    }
}
