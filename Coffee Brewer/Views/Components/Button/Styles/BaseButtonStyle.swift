import SwiftUI

struct BaseButtonStyle: ButtonStyle {
    var maxWidth: CGFloat? = .infinity
    
    // Common animation and interaction properties
    func applyBaseStyle<V: View>(_ content: V, isPressed: Bool) -> some View {
        content
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: maxWidth)
    }
}
