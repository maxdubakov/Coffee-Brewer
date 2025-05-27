import SwiftUI

struct BaseButtonStyle: ButtonStyle {
    var maxWidth: CGFloat? = .infinity
    
    // Common animation and interaction properties
    func applyBaseStyle<V: View>(_ content: V, isPressed: Bool) -> some View {
        content
            .buttonPressAnimation(isPressed: isPressed)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: maxWidth)
    }
}
