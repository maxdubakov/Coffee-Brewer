import SwiftUI

// MARK: - Animation Modifiers

/// Bounce animation for arrows and directional indicators
struct BounceAnimation: ViewModifier {
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    offset = -10
                }
            }
    }
}

/// Pulse animation for highlighting important elements
struct PulseAnimation: ViewModifier {
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    scale = 1.05
                }
            }
    }
}

/// Scale animation for appearing elements
struct ScaleAnimation: ViewModifier {
    @State private var scale: CGFloat = 0.8
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
    }
}

/// Button press animation with scale and opacity
struct ButtonPressAnimation: ViewModifier {
    let isPressed: Bool
    var scale: CGFloat = 0.98
    var opacity: CGFloat = 0.9
    var duration: Double = 0.2
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .opacity(isPressed ? opacity : 1.0)
            .animation(.easeInOut(duration: duration), value: isPressed)
    }
}

/// Fade animation for appearing/disappearing elements
struct FadeAnimation: ViewModifier {
    let isVisible: Bool
    var duration: Double = 0.3
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeOut(duration: duration), value: isVisible)
    }
}

/// Progress animation for smooth transitions
struct ProgressAnimation: ViewModifier {
    let value: Double
    var duration: Double = 0.3
    
    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: duration), value: value)
    }
}

// MARK: - Animation Constants

enum AnimationDurations {
    static let buttonPress: Double = 0.2
    static let quickFade: Double = 0.1
    static let standardFade: Double = 0.3
    static let progress: Double = 0.3
    static let spring: Double = 0.5
}

enum AnimationScales {
    static let buttonPress: CGFloat = 0.98
    static let buttonPressSmall: CGFloat = 0.95
    static let pulse: CGFloat = 1.05
    static let initialScale: CGFloat = 0.8
}

// MARK: - View Extensions

extension View {
    /// Apply bounce animation to the view
    func bounceAnimation() -> some View {
        modifier(BounceAnimation())
    }
    
    /// Apply pulse animation to the view
    func pulseAnimation() -> some View {
        modifier(PulseAnimation())
    }
    
    /// Apply scale animation to the view
    func scaleAnimation() -> some View {
        modifier(ScaleAnimation())
    }
    
    /// Apply button press animation
    func buttonPressAnimation(isPressed: Bool, scale: CGFloat = AnimationScales.buttonPress, opacity: CGFloat = 0.9, duration: Double = AnimationDurations.buttonPress) -> some View {
        modifier(ButtonPressAnimation(isPressed: isPressed, scale: scale, opacity: opacity, duration: duration))
    }
    
    /// Apply fade animation
    func fadeAnimation(isVisible: Bool, duration: Double = AnimationDurations.standardFade) -> some View {
        modifier(FadeAnimation(isVisible: isVisible, duration: duration))
    }
    
    /// Apply progress animation
    func progressAnimation(value: Double, duration: Double = AnimationDurations.progress) -> some View {
        modifier(ProgressAnimation(value: value, duration: duration))
    }
}