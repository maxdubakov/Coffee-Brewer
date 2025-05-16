import SwiftUI

struct DestructiveButtonStyle: ButtonStyle {
    var maxWidth: CGFloat? = .infinity
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .frame(maxWidth: maxWidth)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.9, green: 0.25, blue: 0.25), Color(red: 0.75, green: 0.15, blue: 0.15)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
